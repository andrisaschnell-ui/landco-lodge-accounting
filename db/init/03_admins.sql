-- ============================================================
-- SQL: Seed Admin Users
-- ============================================================

-- Inserting into auth.users (Final Verified Sign-ins)
INSERT INTO auth.users (email, password_hash, display_name)
VALUES 
  ('cwschnell@gmail.com', '$2a$10$9SpDaadZmgnD9g7JA.YzP.L8s/hQBmmoLBxR7SwdO8vYatp4MyQ3O', 'Gordon Board'),
  ('andrisa.schnell@gmail.com', '$2a$10$yvMx4.xTwEwd8aTe2ewPmOyaKyj2z2//cBurlk0P9fZPDAzNVHAGa', 'Andrisa Schnell')
ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash;

-- Map Admins to Roles
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin'::public.app_role FROM auth.users
WHERE email IN ('cwschnell@gmail.com','andrisa.schnell@gmail.com')
ON CONFLICT DO NOTHING;

-- Map to Profiles
INSERT INTO public.profiles (user_id, email, display_name)
SELECT id, email, display_name FROM auth.users
WHERE email IN ('cwschnell@gmail.com','andrisa.schnell@gmail.com')
AND id NOT IN (SELECT user_id FROM public.profiles WHERE user_id IS NOT NULL);
