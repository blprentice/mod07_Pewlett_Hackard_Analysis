--  Data is from https://github.com/vrajmohan/pgsql-sample-data/tree/master/employee
-- Creating tables for PH-EmployeeDB

CREATE TABLE departments (
  dept_no VARCHAR(4) NOT NULL,
  dept_name VARCHAR(40) NOT NULL,
  PRIMARY KEY (dept_no),
  UNIQUE (dept_name)
);

CREATE TABLE employees (
  emp_no INT NOT NULL,
  birth_date DATE NOT NULL,
  first_name VARCHAR NOT NULL,
  last_name VARCHAR NOT NULL,
  gender VARCHAR NOT NULL,
  hire_date DATE NOT NULL,
  PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR(50) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, title, from_date)
);

CREATE TABLE salaries (
	emp_no INT NOT NULL,
	salary INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	PRIMARY KEY (emp_no, from_date)
);

-- Create a table holding retiring employees by job title

SELECT e.emp_no,
	e.first_name,
	e.last_name,
	ti.title,
	ti.from_date,
	ti.to_date
	
INTO retirement_titles
	
FROM employees AS e

INNER JOIN titles as ti

ON e.emp_no = ti.emp_no

WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')

ORDER BY emp_no;

-- Remove duplicate records based on employee job titles

SELECT DISTINCT ON (emp_no) emp_no, 
	first_name, 
	last_name, 
	title

INTO unique_titles

FROM retirement_titles

WHERE to_date = '9999-01-01'

ORDER BY emp_no, to_date DESC;

-- Create a table with the number of retiring employees by most recent job title

SELECT COUNT(title), title

INTO retiring_titles

FROM unique_titles

GROUP BY title

ORDER BY COUNT DESC;

-- Create a table including employees eligible for mentorship program

SELECT DISTINCT ON (e.emp_no) e.emp_no,
	e.first_name,
	e.last_name,
	e.birth_date,
	de.from_date,
	de.to_date,
	ti.title
	
INTO mentorship_eligibility

FROM employees AS e

INNER JOIN dept_emp AS de

ON (e.emp_no = de.emp_no)

INNER JOIN titles AS ti

ON (e.emp_no = ti.emp_no)

WHERE (de.to_date = '9999-01-01' 
	   AND e.birth_date BETWEEN '1965-01-01' AND '1965-12-31')
	   
ORDER BY e.emp_no;