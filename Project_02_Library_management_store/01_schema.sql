-- 1. Authors Table
CREATE TABLE authors (
    author_id INT PRIMARY KEY,
    author_name VARCHAR(150) NOT NULL,
    nationality VARCHAR(100), 
    birth_year INT,
    biography TEXT 
);

-- 2. Books Table
CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(50) UNIQUE,
    genre VARCHAR(100) NOT NULL, 
    publisher VARCHAR(150),   
    publication_year INT,
    purchase_cost DECIMAL(8,2) NOT NULL, 
    total_copies INT NOT NULL CHECK (total_copies >= 0),
    available_copies INT NOT NULL CHECK (available_copies <= total_copies),
    rating DECIMAL(3,2)        
);

-- 3. Many-to-Many Bridge Table (Books <-> Authors)
CREATE TABLE book_authors (
    book_id INT REFERENCES books(book_id) ON DELETE CASCADE,
    author_id INT REFERENCES authors(author_id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, author_id)
);

-- 4. Members Table
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150),       
    phone VARCHAR(50),        
    membership_date DATE NOT NULL,
    membership_tier VARCHAR(50) DEFAULT 'Standard', 
    status VARCHAR(50) DEFAULT 'Active' 
);

-- 5. Staff Table (Created BEFORE dependent tables)
CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    role VARCHAR(100) DEFAULT 'Librarian', 
    salary DECIMAL(10,2),
    hire_date DATE NOT NULL,
    managed_by INT REFERENCES staff(staff_id) 
);

-- 6. Book Loans Table (With explicit staff tracking built-in)
CREATE TABLE book_loans (
    loan_id INT PRIMARY KEY,
    book_id INT REFERENCES books(book_id) ON DELETE CASCADE,
    member_id INT REFERENCES members(member_id) ON DELETE CASCADE,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,         
    accrued_fine DECIMAL(6,2) DEFAULT 0.00,
    issued_by INT REFERENCES staff(staff_id) -- Built directly!
);

-- 7. Reservations Table
CREATE TABLE book_reservations (
    reservation_id INT PRIMARY KEY,
    book_id INT REFERENCES books(book_id) ON DELETE CASCADE,
    member_id INT REFERENCES members(member_id) ON DELETE CASCADE,
    reservation_date DATE NOT NULL,
    reservation_status VARCHAR(50) DEFAULT 'Pending' 
);

-- 8. Fine Payments Ledger Table (With staff processing built-in)
CREATE TABLE fine_payments (
    payment_id INT PRIMARY KEY,
    loan_id INT REFERENCES book_loans(loan_id) ON DELETE CASCADE,
    amount_paid DECIMAL(6,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(50), 
    processed_by INT REFERENCES staff(staff_id) -- Built directly!
);
-- Schema created Successfully.