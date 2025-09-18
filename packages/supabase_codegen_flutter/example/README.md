# Supabase Codegen Example

This is an example project demonstrating the use of the [Supabase Codegen Library](https://pub.dev/packages/supabase_codegen)

## Prerequisites
- [Supabase CLI]()

## Getting Started

- Start supabase project: 
```bash
supabase start
```

- Add codegen functions: 
```bash
dart run supabase_codegen:add_codegen_functions
```

- Setup database locally  
  This will [create the tables](supabase/migrations/20250412000032_setup_db.sql) in the database and add [sample data](supabase/seed.sql)
```bash
supabase db reset
```  

- Install dependencies: 
```bash
flutter pub get
```

- Copy `.env.example` to `.env` and update the values
```bash
cp .env.example .env
```

- Generate types: 
```bash
dart run supabase_codegen:generate_types
```

- Run project
```bash
flutter run [platform]
```