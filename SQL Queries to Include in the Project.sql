-- e-commerce platform analysis

-- 1. tables

create table users (
    user_id int primary key,
    name varchar(100),
    email varchar(100),
    signup_date date,
    gender varchar(10),
    age int,
    city varchar(50),
    state varchar(50)
);

create table categories (
    category_id int primary key,
    category_name varchar(100)
);
 
create table products (
    product_id int primary key,
    name varchar(100),
    category_id int,
    price decimal(10,2),
    brand varchar(50),
    foreign key (category_id) references categories(category_id)
);

create table orders (
    order_id int primary key,
    user_id int,
    order_date date,
    status varchar(20),
    payment_method varchar(50),
    total_amount decimal(10,2),
    foreign key (user_id) references users(user_id)
);

create table order_items (
    order_item_id int primary key,
    order_id int,
    product_id int,
    quantity int,
    item_price decimal(10,2),
    foreign key (order_id) references orders(order_id),
    foreign key (product_id) references products(product_id)
);
create table reviews (
    review_id int primary key,
    user_id int,
    product_id int,
    rating int,
    review_text text,
    review_date date,
    foreign key (user_id) references users(user_id),
    foreign key (product_id) references products(product_id)
);

-- 2. data
insert into categories values
(1, "clothing"), (2, "electronics"), (3, "footwear"), (4, "home decor");

insert into users values
(1, "aman", "aman@example.com", "2022-01-05", "male", 24, "delhi", "delhi"),
(2, "riya", "riya@example.com", "2022-03-15", "female", 28, "mumbai", "maharashtra"),
(3, "suresh", "suresh@example.com", "2023-07-10", "male", 35, "kolkata", "west bengal");

insert into products values
(101, "t-shirt", 1, 499.00, "nike"),
(102, "headphones", 2, 2499.00, "jbl"),
(103, "sneakers", 3, 1999.00, "puma"),
(104, "wall clock", 4, 899.00, "ajanta");

insert into orders values
(1001, 1, "2024-07-01", "delivered", "credit card", 2998.00),
(1002, 2, "2024-07-03", "delivered", "upi", 1999.00),
(1003, 3, "2024-07-05", "cancelled", "cash on delivery", 899.00);

insert into order_items values
(1, 1001, 101, 2, 998.00),
(2, 1001, 102, 1, 2499.00),
(3, 1002, 103, 1, 1999.00),
(4, 1003, 104, 1, 899.00);

insert into reviews values
(1, 1, 101, 4, "good quality t-shirt", "2024-07-02"),
(2, 2, 103, 5, "very comfortable sneakers", "2024-07-04");


-- monthly revenue summary
select month(order_date) as month, sum(total_amount) as revenue
from orders
where status = "delivered"
group by month(order_date)
order by month;

-- top categories by revenue
select c.category_name, sum(oi.item_price * oi.quantity) as revenue
from order_items oi
join products p on oi.product_id = p.product_id
join categories c on p.category_id = c.category_id
join orders o on oi.order_id = o.order_id
where o.status = "delivered"
group by c.category_name
order by revenue desc;

-- customer lifetime value
select u.user_id, u.name, sum(o.total_amount) as total_spent
from users u
join orders o on u.user_id = o.user_id
where o.status = "delivered"
group by u.user_id, u.name
order by total_spent desc;

-- product ratings summary
select p.name, avg(r.rating) as avg_rating, count(r.review_id) as total_reviews
from reviews r
join products p on r.product_id = p.product_id
group by p.name
order by avg_rating desc;

-- order cancellation rate by state
select u.state, 
    count(case when o.status = "cancelled" then 1 end) * 100.0 / count(*) as cancellation_rate
from orders o
join users u on o.user_id = u.user_id
group by u.state;
