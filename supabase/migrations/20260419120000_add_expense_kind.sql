-- =============================================================================
-- Add expense kind to public.transactions + log_expense() RPC.
--
-- HOW TO APPLY: this project doesn't have a CLI-driven migration runner yet
-- (per plan.md §6.2 — SQL goes through the Supabase SQL Editor). Paste the
-- contents of this file into Supabase → SQL Editor → New query → Run, all
-- in one go (it's a single transaction-safe block).
--
-- What it adds:
--   1. A `kind` discriminator on `public.transactions` so the same ledger
--      can hold both peer-to-peer family transfers AND outside-the-family
--      expenses ("PlayStation Network", "Uber", "Burger King", ...).
--   2. Optional `description` + `category` columns for expense rows.
--   3. Relaxes the NOT NULL on `receiver_id` because expenses have no
--      family-internal recipient — guarded by a CHECK so transfers still
--      require it.
--   4. A new SECURITY DEFINER RPC `log_expense(amount, description, category)`
--      that decrements the caller's balance and inserts the row atomically,
--      reusing the existing `enforce_monthly_limit(child_id, amount)`
--      semantics for child users.
--
-- The existing `transactions_family_select` RLS policy is keyed off
-- `family_id` so expense rows are visible to the same audience as transfer
-- rows — no policy change needed. (Confirm in the SQL Editor's Policies
-- panel after running this if you've customised RLS.)
-- =============================================================================

begin;

-- 1. Schema additions ---------------------------------------------------------

alter table public.transactions
  add column if not exists kind text not null default 'transfer';

alter table public.transactions
  add column if not exists description text;

alter table public.transactions
  add column if not exists category text;

-- Drop the legacy NOT NULL on receiver_id; we re-impose the invariant via
-- a CHECK that depends on `kind` below.
alter table public.transactions
  alter column receiver_id drop not null;

-- Idempotent constraint adds: drop-if-exists then add, because Postgres
-- doesn't have `add constraint if not exists`.
alter table public.transactions
  drop constraint if exists transactions_kind_check;
alter table public.transactions
  add constraint transactions_kind_check
  check (kind in ('transfer', 'expense'));

alter table public.transactions
  drop constraint if exists transactions_category_check;
alter table public.transactions
  add constraint transactions_category_check
  check (
    category is null
    or category in (
      'groceries', 'dining', 'entertainment', 'transport',
      'shopping', 'bills', 'health', 'education', 'other'
    )
  );

alter table public.transactions
  drop constraint if exists transactions_description_length_check;
alter table public.transactions
  add constraint transactions_description_length_check
  check (description is null or char_length(description) between 1 and 80);

-- A transfer must have a receiver; an expense must NOT have one. Also
-- requires every expense to carry a category (transfers don't).
alter table public.transactions
  drop constraint if exists transactions_kind_shape_check;
alter table public.transactions
  add constraint transactions_kind_shape_check
  check (
    (kind = 'transfer' and receiver_id is not null)
    or (kind = 'expense' and receiver_id is null and category is not null
        and description is not null)
  );

-- 2. log_expense RPC ----------------------------------------------------------

create or replace function public.log_expense(
  p_amount      bigint,
  p_description text,
  p_category    text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_caller   uuid := auth.uid();
  v_family   uuid;
  v_role     text;
  v_balance  bigint;
  v_clean    text;
  v_tx_id    uuid;
begin
  if v_caller is null then
    raise exception 'Not authenticated' using errcode = '28000';
  end if;

  if p_amount is null or p_amount <= 0 then
    raise exception 'Amount must be positive' using errcode = '22023';
  end if;

  v_clean := nullif(btrim(coalesce(p_description, '')), '');
  if v_clean is null then
    raise exception 'Description is required' using errcode = '22023';
  end if;
  if char_length(v_clean) > 80 then
    raise exception 'Description too long' using errcode = '22023';
  end if;

  if p_category is null or p_category not in (
    'groceries', 'dining', 'entertainment', 'transport',
    'shopping', 'bills', 'health', 'education', 'other'
  ) then
    raise exception 'Invalid category' using errcode = '22023';
  end if;

  -- Resolve caller's family + role + lock their profile row to avoid
  -- a concurrent transfer racing the balance check.
  select family_id, role::text, balance
    into v_family, v_role, v_balance
    from public.profiles
   where id = v_caller
   for update;

  if v_family is null then
    raise exception 'Caller has no family' using errcode = '42501';
  end if;

  if v_balance < p_amount then
    raise exception 'Insufficient balance' using errcode = '22023';
  end if;

  -- Mirror transfer_money's monthly-cap behaviour for child accounts. We
  -- call the same helper so the limit semantics stay in lockstep.
  if v_role = 'child' then
    perform public.enforce_monthly_limit(v_caller, p_amount);
  end if;

  update public.profiles
     set balance = balance - p_amount
   where id = v_caller;

  insert into public.transactions
    (family_id, sender_id, receiver_id, amount, kind, description, category)
  values
    (v_family, v_caller, null, p_amount, 'expense', v_clean, p_category)
  returning id into v_tx_id;

  return v_tx_id;
end;
$$;

revoke all on function public.log_expense(bigint, text, text) from public;
grant execute on function public.log_expense(bigint, text, text) to authenticated;

commit;
