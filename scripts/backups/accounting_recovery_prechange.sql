--
-- PostgreSQL database dump
--

\restrict d3EeO9XscCMaaatnSbsv97JdCoL3siiKbV1VNTmNLyS400g3i00Rcqo4zxD5eYm

-- Dumped from database version 15.17
-- Dumped by pg_dump version 15.17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: income_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.income_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date date NOT NULL,
    property_id uuid,
    guest_name text,
    description text,
    accommodation_amount_mzn numeric DEFAULT 0 NOT NULL,
    amount_usd numeric DEFAULT 0,
    month integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    journal_entry_id uuid
);


ALTER TABLE public.income_transactions OWNER TO postgres;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    invoice_number text NOT NULL,
    invoice_series text DEFAULT 'FT'::text NOT NULL,
    invoice_date date NOT NULL,
    due_date date,
    property_id uuid,
    client_name text NOT NULL,
    client_nuit text,
    client_address text,
    line_items jsonb DEFAULT '[]'::jsonb NOT NULL,
    subtotal_mzn numeric DEFAULT 0 NOT NULL,
    vat_amount_mzn numeric DEFAULT 0 NOT NULL,
    total_mzn numeric DEFAULT 0 NOT NULL,
    currency text DEFAULT 'MZN'::text NOT NULL,
    exchange_rate numeric DEFAULT 1,
    status text DEFAULT 'draft'::text NOT NULL,
    at_hash text,
    at_qr_code text,
    journal_entry_id uuid,
    income_tx_id uuid,
    issued_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: journal_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journal_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entry_date date NOT NULL,
    reference text,
    description text NOT NULL,
    entry_type text NOT NULL,
    property_id uuid,
    posted boolean DEFAULT false NOT NULL,
    posted_at timestamp with time zone,
    posted_by uuid,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.journal_entries OWNER TO postgres;

--
-- Name: journal_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journal_lines (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    journal_entry_id uuid NOT NULL,
    account_id uuid NOT NULL,
    debit numeric DEFAULT 0 NOT NULL,
    credit numeric DEFAULT 0 NOT NULL,
    memo text,
    CONSTRAINT journal_lines_check CHECK (((debit = (0)::numeric) OR (credit = (0)::numeric))),
    CONSTRAINT journal_lines_credit_check CHECK ((credit >= (0)::numeric)),
    CONSTRAINT journal_lines_debit_check CHECK ((debit >= (0)::numeric))
);


ALTER TABLE public.journal_lines OWNER TO postgres;

--
-- Name: petty_cash_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.petty_cash_transactions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date date,
    description text NOT NULL,
    credit numeric DEFAULT 0,
    debit numeric DEFAULT 0,
    balance numeric DEFAULT 0,
    month integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.petty_cash_transactions OWNER TO postgres;

--
-- Data for Name: income_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.income_transactions (id, date, property_id, guest_name, description, accommodation_amount_mzn, amount_usd, month, year, created_at, updated_at, journal_entry_id) FROM stdin;
3441bc57-1201-4661-abfa-bc2e3e4d60c8	2025-01-02	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	594297.00	9396.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
ac54c013-7df0-4e4c-b19a-13d889415553	2025-01-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
18d3f604-37c7-42c3-acf0-329402d9c5a2	2025-01-24	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	293480.00	4640.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
3e80cd1d-a1cf-4cf2-90b5-cd58158b9332	2025-02-25	b0e3af81-86f7-4e03-8742-a859303b62a6	CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	\N	40200.00	600.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
1d9d385f-ed79-4077-a5db-341c12ed022b	2025-03-04	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	751171.00	11876.22	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
789c18ea-2005-443a-9510-2c4fca7a87f9	2025-03-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN PAY TRACY SALARY AND RECRUITMENT	\N	458172.00	6942.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
a28b19bd-9454-4c85-ad33-466f2a89d209	2025-03-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
5d5f37de-0766-4c31-ba8c-870f26f4c22f	2025-03-25	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	132000.00	2000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
96bba594-dfc3-4654-91f4-6d134c5dadde	2025-04-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ROBIN	\N	465650.00	6950.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
efa13fc6-51e7-4159-8092-5dfe792789b5	2025-04-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON 7 DAYS @80	\N	37520.00	560.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
0d90e6c9-be85-41ce-96b4-2343d69151d1	2025-04-30	b0e3af81-86f7-4e03-8742-a859303b62a6	KEIVIN PAY TO BANK	\N	420000.00	6640.32	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
4533942f-8e27-4722-816e-1c796ebd4da6	2025-05-23	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM AANGIE	\N	310000.00	5000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
813a09c4-8af9-41bc-8ab3-cc3420fe835b	2025-06-03	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	ALEX	\N	958350.00	15151.78	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
41e28b7a-9c7e-4dd6-898d-6ea9df96c643	2025-06-20	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
7e2a35d2-71e6-46ac-8f06-d56d12911c46	2025-06-21	b0e3af81-86f7-4e03-8742-a859303b62a6	WARREN STEAD	\N	958350.00	15151.78	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
f30da5de-4f59-4ca6-aa69-f846cc4eea72	2025-07-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ALEX	\N	335000.00	5000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
ace94d66-9bf5-4589-956a-396e4da8d5e6	2025-07-17	6214c344-b5f9-4d17-b539-e367889ffa9c	ARON ACCOMMODATION IN H4	\N	98490.00	1470.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
1069f22a-2c07-4a0b-812c-add966df5081	2025-08-11	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	CREDIT IVA H1 - LESLEY X 6 NIGHTS	\N	68000.00	1000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
47e07600-702f-47af-8957-0312b2ff88cc	2025-08-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN	\N	119000.00	1750.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
eba45d1f-c23d-42f0-ae7c-f93787fc4a83	2025-09-12	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	638900.00	10101.19	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
4592d261-0399-49c6-b5f2-1bae4157cbab	2025-09-22	6214c344-b5f9-4d17-b539-e367889ffa9c	ALAIN WARREN	\N	60720.00	880.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
3dae6133-5ded-4d21-9d3c-eb1481682f49	2025-10-10	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	941920.00	14892.02	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
07180c22-6e02-4743-aa3d-e1fa46c9b694	2025-10-23	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX TRANSFER TO MONIQUE	\N	222300.00	3000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
3f5eba4a-fe6f-41d8-b744-07d882e169a2	2025-10-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
1a4536c7-23a9-4ee5-9314-a570c2eaff6b	2025-11-18	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	948750.00	15000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
234ed239-5b62-41a3-abd2-1400a195e4df	2025-11-19	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	22400.00	320.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
61d29e92-e33c-4f75-b76d-d37f390ee338	2025-11-25	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	551000.00	8711.46	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
5da3732e-28aa-45b6-a283-c8ac855bf591	2025-12-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	55200.00	800.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
b4939f29-4b22-484c-b543-6113ca54b506	2025-12-29	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RE ROBIN	\N	207000.00	3000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
f4533932-e0c5-4907-a863-aaa214cb6e69	2025-12-29	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN INVESTMENT DOLLAR ACCOUNT	\N	569250.00	9000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
a1f9cb9f-6a81-4a8e-a42c-2220d6340850	2026-01-09	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD DEP BANK	\N	948750.00	15000.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
6296370c-b299-4c47-b5bd-c03e1bf622a9	2026-01-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	812375.00	12125.00	1	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
89416c2c-c14d-4595-a3f6-a03ef0067c65	2025-01-02	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	594297.00	9396.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
ac45973e-7fce-449d-9517-e81b3eca33af	2025-01-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
bf9e2cf4-6cb0-4a25-9903-c0423e0a3794	2025-01-24	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	293480.00	4640.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
88e4aaa9-1c37-4bff-b576-537e13c21c49	2025-02-25	b0e3af81-86f7-4e03-8742-a859303b62a6	CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	\N	40200.00	600.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
28d743c5-c796-43cf-95a7-56675fbfc003	2025-03-04	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	751171.00	11876.22	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
8efa9f82-4b4f-4c07-8e39-f3460e0323ff	2025-03-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN PAY TRACY SALARY AND RECRUITMENT	\N	458172.00	6942.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
5d92494f-2e2c-4490-9707-f36b342659c7	2025-03-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
e3c36357-efda-449f-ac66-7995134b348b	2025-03-25	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	132000.00	2000.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
43303196-8ac1-4e73-af2d-ee85e166851b	2025-04-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ROBIN	\N	465650.00	6950.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
2679859c-de01-4d94-addc-c827ef72a59f	2025-04-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON 7 DAYS @80	\N	37520.00	560.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
32e3ecf3-b6bf-44d0-95ba-1aef3bdd20e2	2025-04-30	b0e3af81-86f7-4e03-8742-a859303b62a6	KEIVIN PAY TO BANK	\N	420000.00	6640.32	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
0954ba9d-44f9-49ce-9be7-202a9406c7ab	2025-05-23	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM AANGIE	\N	310000.00	5000.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
e3243d26-075f-46b8-bb97-9a705e26a74f	2025-06-03	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	ALEX	\N	958350.00	15151.78	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
39a7511c-ffc3-4a1d-afd8-133709ae055b	2025-06-20	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
1b39ccd0-eb2f-430b-8c68-2bb09896df92	2025-06-21	b0e3af81-86f7-4e03-8742-a859303b62a6	WARREN STEAD	\N	958350.00	15151.78	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
f00adeab-dfff-432a-9ace-dbf5cc31f1db	2025-07-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ALEX	\N	335000.00	5000.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
2e3dfdb0-10d6-4e67-84da-5afd6adf8210	2025-07-17	6214c344-b5f9-4d17-b539-e367889ffa9c	ARON ACCOMMODATION IN H4	\N	98490.00	1470.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
42cb4ea2-d9f9-4cbd-a995-a3bcddd54631	2025-08-11	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	CREDIT IVA H1 - LESLEY X 6 NIGHTS	\N	68000.00	1000.00	2	2026	2026-04-13 09:06:45.972972+00	2026-04-13 09:06:45.972972+00	\N
61ce52c7-4a9c-4f3f-bfac-58bf65fabfca	2025-08-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN	\N	119000.00	1750.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
8668bd99-27c2-4582-ba7d-407981a4e034	2025-09-12	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	638900.00	10101.19	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
c068d7bf-1c26-46a3-bab9-a112ce006ddf	2025-09-22	6214c344-b5f9-4d17-b539-e367889ffa9c	ALAIN WARREN	\N	60720.00	880.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
aa467779-c14a-4d6f-a6b9-35ac5b6eee12	2025-10-10	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	941920.00	14892.02	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
4ebfbc50-3764-4c6e-ac5f-978bf0566cad	2025-10-23	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX TRANSFER TO MONIQUE	\N	222300.00	3000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
f59bd5ac-d1fe-4f3d-a5f7-f73bfa63f7c5	2025-10-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
1b490664-acec-4935-8cf7-04f0f49edd35	2025-11-18	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	948750.00	15000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
f05a6a09-cb41-44ef-b600-fcf2752ae029	2025-11-19	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	22400.00	320.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
d421f077-7168-4dbb-9f8f-36ec861147ea	2025-11-25	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	551000.00	8711.46	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
6fb177a6-bfd7-45b3-8392-fd467b7daff1	2025-12-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	55200.00	800.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
28c75f42-ac37-48d9-8789-0b7e5555dbbe	2025-12-29	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RE ROBIN	\N	207000.00	3000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
9adaaca4-826b-48b3-8c21-bb5a1cc859bc	2025-12-29	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN INVESTMENT DOLLAR ACCOUNT	\N	569250.00	9000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
58d63911-f366-4cc3-aa61-b91c17923f34	2026-01-09	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD DEP BANK	\N	948750.00	15000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
b9c93133-281f-405c-8170-142fdadaf55c	2026-01-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	812375.00	12125.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
ffbc4f79-e222-400d-97d7-19f797f13b07	2026-02-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	335000.00	5000.00	2	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
bce9e8ec-c843-473a-b25c-0cfee9bf62ba	2025-01-02	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	594297.00	9396.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
ae3885b7-6e81-4264-b7bb-e4596aa912d6	2025-01-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
4efa6d72-b18c-4c72-a374-e500c41a048a	2025-01-24	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	293480.00	4640.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
70bb260c-b1e5-4576-9f1f-f6ffbdc16712	2025-02-25	b0e3af81-86f7-4e03-8742-a859303b62a6	CREDIT IVA H3 - KEITH & SUE X 8 NIGHTS @ 75	\N	40200.00	600.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
c8a920cf-32cc-4688-988e-3c5cbdefdd80	2025-03-04	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	751171.00	11876.22	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
365ef547-7b02-45eb-a8b4-9d80ed21fcbb	2025-03-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN PAY TRACY SALARY AND RECRUITMENT	\N	458172.00	6942.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
e4ce331c-97d3-4f10-8358-54defd15f2f8	2025-03-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	958350.00	15151.78	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
79eb54a8-59f1-4338-85ce-bdaf666a1923	2025-03-25	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	132000.00	2000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
03d462fe-3b12-4f49-8a73-ac2fd9bc0a4b	2025-04-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ROBIN	\N	465650.00	6950.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
82672f4e-fbdf-4cb3-bc5c-22654fadb3ea	2025-04-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON 7 DAYS @80	\N	37520.00	560.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
c4145cdc-0c44-419c-a0c0-554fd67b4e79	2025-04-30	b0e3af81-86f7-4e03-8742-a859303b62a6	KEIVIN PAY TO BANK	\N	420000.00	6640.32	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
c9fe6b5e-0a00-4f52-9d29-8059c20f0445	2025-05-23	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM AANGIE	\N	310000.00	5000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
507baae5-9a0d-4fe2-a281-664ce6b9abe3	2025-06-03	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	ALEX	\N	958350.00	15151.78	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
aafdbadf-98d3-41d7-8d44-77136e1f6ffb	2025-06-20	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
0c836e99-c20a-4c86-95a3-756407ae2d31	2025-06-21	b0e3af81-86f7-4e03-8742-a859303b62a6	WARREN STEAD	\N	958350.00	15151.78	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
8f6349f7-9cc0-47a2-a156-d18152937a14	2025-07-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RECEIVED FROM ALEX	\N	335000.00	5000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
0a9819b0-e317-44df-9c31-4a72beeb1733	2025-07-17	6214c344-b5f9-4d17-b539-e367889ffa9c	ARON ACCOMMODATION IN H4	\N	98490.00	1470.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
9709da80-d9bf-4352-a39d-70b54c30262e	2025-08-11	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	CREDIT IVA H1 - LESLEY X 6 NIGHTS	\N	68000.00	1000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
3bde08ef-4fdb-47d0-99ea-8a74ff0622df	2025-08-25	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN	\N	119000.00	1750.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
46c7037b-5b3b-4fd4-be66-1c95614263af	2025-09-12	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	638900.00	10101.19	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
c9b0c7a8-91b0-442a-abf9-bf828612e05f	2025-09-22	6214c344-b5f9-4d17-b539-e367889ffa9c	ALAIN WARREN	\N	60720.00	880.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
65450fd3-8332-42b9-be13-64b6ead6589d	2025-10-10	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD	\N	941920.00	14892.02	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
a8c0e208-b799-4aab-aee3-9f687e8847b3	2025-10-23	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX TRANSFER TO MONIQUE	\N	222300.00	3000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
d59bcdbf-c2bf-4f0f-a00e-236cdf78809f	2025-10-24	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	948750.00	15000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
6f82d966-5bc5-49ac-8821-6e7b6ad78ff7	2025-11-18	b0e3af81-86f7-4e03-8742-a859303b62a6	ALEX	\N	948750.00	15000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
0a2d282f-f83c-4536-8352-7367b8d6fce1	2025-11-19	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	22400.00	320.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
41130366-59b1-4dbd-ab1f-a3635184e276	2025-11-25	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	551000.00	8711.46	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
2aba1003-4b22-4460-a3ac-b4849587c5b0	2025-12-16	bf17ad40-c04f-4438-8456-1bb96ebcecc7	BRENDON	\N	55200.00	800.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
dd74dd95-4703-4e1a-86e2-3ad6a1f9ce1c	2025-12-29	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY RE ROBIN	\N	207000.00	3000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
8d28d047-767a-47e8-bd14-0ceba680ccde	2025-12-29	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN INVESTMENT DOLLAR ACCOUNT	\N	569250.00	9000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
6c518ca9-1a4a-4dd1-87a8-ddecb93c26ce	2026-01-09	bf17ad40-c04f-4438-8456-1bb96ebcecc7	WARREN STEAD DEP BANK	\N	948750.00	15000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
f1a7da25-4f70-49ac-b20a-9f3bc61859e1	2026-01-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	812375.00	12125.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
4546b618-cf6c-406e-bdf2-97e4232379c3	2026-02-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY	\N	335000.00	5000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
a06e08b9-620e-4a29-9f13-46a732e7b258	2026-03-16	ea35b0ac-a1c4-4269-ac14-c52e1de9d514	TAFY ELIANA	\N	38400.00	607.11	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
32a00646-183b-42d3-9492-0691f03f270a	2026-03-16	6214c344-b5f9-4d17-b539-e367889ffa9c	WARREN COHEN INVESTMENT	\N	1407000.00	21000.00	3	2026	2026-04-13 09:06:46.199479+00	2026-04-13 09:06:46.199479+00	\N
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, invoice_number, invoice_series, invoice_date, due_date, property_id, client_name, client_nuit, client_address, line_items, subtotal_mzn, vat_amount_mzn, total_mzn, currency, exchange_rate, status, at_hash, at_qr_code, journal_entry_id, income_tx_id, issued_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: journal_entries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.journal_entries (id, entry_date, reference, description, entry_type, property_id, posted, posted_at, posted_by, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: journal_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.journal_lines (id, journal_entry_id, account_id, debit, credit, memo) FROM stdin;
\.


--
-- Data for Name: petty_cash_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.petty_cash_transactions (id, date, description, credit, debit, balance, month, year, created_at) FROM stdin;
\.


--
-- Name: income_transactions income_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.income_transactions
    ADD CONSTRAINT income_transactions_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: journal_entries journal_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_pkey PRIMARY KEY (id);


--
-- Name: journal_lines journal_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_pkey PRIMARY KEY (id);


--
-- Name: petty_cash_transactions petty_cash_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.petty_cash_transactions
    ADD CONSTRAINT petty_cash_transactions_pkey PRIMARY KEY (id);


--
-- Name: journal_lines trg_journal_balance; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE CONSTRAINT TRIGGER trg_journal_balance AFTER INSERT OR UPDATE ON public.journal_lines DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION public.check_journal_balance();


--
-- Name: income_transactions income_transactions_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.income_transactions
    ADD CONSTRAINT income_transactions_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- Name: income_transactions income_transactions_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.income_transactions
    ADD CONSTRAINT income_transactions_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: invoices invoices_income_tx_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_income_tx_id_fkey FOREIGN KEY (income_tx_id) REFERENCES public.income_transactions(id);


--
-- Name: invoices invoices_issued_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_issued_by_fkey FOREIGN KEY (issued_by) REFERENCES auth.users(id);


--
-- Name: invoices invoices_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- Name: invoices invoices_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: journal_entries journal_entries_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: journal_entries journal_entries_posted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_posted_by_fkey FOREIGN KEY (posted_by) REFERENCES auth.users(id);


--
-- Name: journal_entries journal_entries_property_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id);


--
-- Name: journal_lines journal_lines_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: journal_lines journal_lines_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id) ON DELETE CASCADE;


--
-- Name: income_transactions Admins can manage income; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage income" ON public.income_transactions TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: petty_cash_transactions Admins can manage petty_cash; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admins can manage petty_cash" ON public.petty_cash_transactions TO authenticated USING (public.has_role(auth.uid(), 'admin'::public.app_role));


--
-- Name: income_transactions Auth can view income; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view income" ON public.income_transactions FOR SELECT TO authenticated USING (true);


--
-- Name: petty_cash_transactions Auth can view petty_cash; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Auth can view petty_cash" ON public.petty_cash_transactions FOR SELECT TO authenticated USING (true);


--
-- Name: income_transactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.income_transactions ENABLE ROW LEVEL SECURITY;

--
-- Name: petty_cash_transactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.petty_cash_transactions ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict d3EeO9XscCMaaatnSbsv97JdCoL3siiKbV1VNTmNLyS400g3i00Rcqo4zxD5eYm

