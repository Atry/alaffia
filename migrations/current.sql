-- Create users table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name TEXT,
    last_name TEXT,
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Smart comment to ensure PostGraphile exposes 'id' properly for GraphQL queries
COMMENT ON COLUMN public.users.id IS E'@primaryKey';

-- Create facilities table
CREATE TABLE IF NOT EXISTS public.facilities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON COLUMN public.facilities.id IS E'@primaryKey';

-- Create locations table
CREATE TABLE IF NOT EXISTS public.locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    facility_id UUID REFERENCES public.facilities(id),
    state TEXT,
    zip TEXT,
    address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON COLUMN public.locations.id IS E'@primaryKey';

-- Create many-to-many relationship between users and facilities
CREATE TABLE IF NOT EXISTS public.user_facilities (
    user_id UUID REFERENCES public.users(id),
    facility_id UUID REFERENCES public.facilities(id),
    PRIMARY KEY (user_id, facility_id)
);

COMMENT ON TABLE public.user_facilities IS E'@compositePrimaryKey (user_id, facility_id)';

-- NOTE: I would never put these in current.sql . This is just for simplicity of this exercise
-- I would normally either set a separate set of migrations for seeding purposes locally for DX...
-- If they are part of integration tests, I would use containerization to run those separately in...
-- a pure test environment that gets sed at start and dropped at end of test runs

-- Migration to seed the users table
INSERT INTO public.users (id, first_name, last_name, email, role, created_at) VALUES
('d6fbc5cf-8c87-442c-9bb9-cfaf4926fe01', 'John', 'Doe', 'john.doe@example.com', 'Doctor', now()),
('a3fbc5cf-8c87-442c-9bb9-cfaf4926fe02', 'Jane', 'Smith', 'jane.smith@example.com', 'Administrator', now())
ON CONFLICT (id) DO NOTHING;;

-- Migration to seed the facilities table
INSERT INTO public.facilities (id, name, created_at) VALUES
('f5af7463-983c-4a1d-8488-44c8188b8ce5', 'Main Hospital', now()),
('40a7bdd0-e1c8-4f6f-9810-03784664ccd9', 'Downtown Clinic', now())
ON CONFLICT (id) DO NOTHING;;

-- Migration to seed the locations table
INSERT INTO public.locations (id, facility_id, state, zip, address, created_at) VALUES
('a8810f61-2f09-4bb8-8b7c-01b1734ddac2', 'f5af7463-983c-4a1d-8488-44c8188b8ce5', 'CA', '90001', '1234 Main St, Los Angeles', now()),
('a21dd2ea-875e-4384-8a15-41efdb5b47b6', '40a7bdd0-e1c8-4f6f-9810-03784664ccd9', 'CA', '90005', '5678 Second St, Los Angeles', now())
ON CONFLICT (id) DO NOTHING;;

-- Migration to create many-to-many relationships between users and facilities
INSERT INTO public.user_facilities (user_id, facility_id) VALUES
('d6fbc5cf-8c87-442c-9bb9-cfaf4926fe01', 'f5af7463-983c-4a1d-8488-44c8188b8ce5'),
('a3fbc5cf-8c87-442c-9bb9-cfaf4926fe02', '40a7bdd0-e1c8-4f6f-9810-03784664ccd9'),
('d6fbc5cf-8c87-442c-9bb9-cfaf4926fe01', '40a7bdd0-e1c8-4f6f-9810-03784664ccd9')  -- John Doe is busy dude, he works for both hospitals!
ON CONFLICT (user_id, facility_id) DO NOTHING;