Create database offbeatz;
Use offbeatz;



create table customer(
    customer_id  int unsigned not null auto_increment primary key,
     name  varchar(255) not null
    email   varchar(255) not null unique
    password varchar(255) not null
    phone  varchar(255) not null,
    created_at datetime not null default current_timestamp
)engine = innodb;


create table address(
    address_id int unsigned auto_increment primary key,
    street varchar(255) not null,
    block varchar(255) not null,
    city varchar(255) not null,
    postal_code varchar(255) not null
    customer_id int unsigned not null

    constraint fk_customer_id 
    foreign key (customer_id) refernces customer(customer_id)

    on delete cascade
    on update restrict
) engine = innodb;


create table category(
    category_id  int unsigned not null auto_increment primary key,
     name  varchar(255) not null
    customisable varchar(255) not null,
)engine = innodb;


Create table product(
Product_id int unsigned not null auto_increment primary key,
Name varchar(255) not null,
Description text
Price decimal(10, 2) not null
Category_id int unsigned not null

    constraint fk_category_id 
    foreign key (category_id) refernces customer(category_id)
    on delete cascade
    on update restrict
) engine = innodb;



CREATE TABLE variant (
    Variant_id          INT AUTO_INCREMENT PRIMARY KEY,
    product_id  INT NOT NULL,
    sku         VARCHAR(50) NOT NULL UNIQUE,
    size        VARCHAR(20),
    color       VARCHAR(30),
    stock_qty   INT NOT NULL DEFAULT 
   product_id int unsigned not null

    constraint fk_product_id 
    foreign key (product_id) refernces customer(product_id)
    on delete cascade
    on update restrict
) engine = innodb;


CREATE TABLE orders (
    Order_id          int auto_increment primary key,  
    status       enum 'pending','paid','shipped','delivered','cancelled')
                 NOT NULL DEFAULT 'pending',
    total        DECIMAL(10,2) NOT NULL DEFAULT,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    customer_id   int unsigned not null,
    address_id   int unsigned not null

    constraint fk_customer_id 
    foreign key (customer_id) references customer(customer_id)
    on delete cascade
    on update restrict

    constraint fk_address_id 
    foreign key (address_id) references customer(address_id)
    on delete cascade
    on update restrict

) engine = innodb;


CREATE TABLE order_item (
    Order_item_id          INT AUTO_INCREMENT PRIMARY KEY,
    quantity    INT NOT NULL,
    unit_price  DECIMAL(10,2) NOT NULL,
    order_id    int unsigned not null 
    variant_id  int unsigned not null

    constraint fk_order_id 
    foreign key (order_id) references customer(order_id)
    on delete cascade
    on update restrict

    constraint fk_variant_id 
    foreign key (variant_id) references customer(variant_id)
    on delete cascade
    on update restrict

) engine = innodb;


-- One custom design per order item (only for customised jerseys)
CREATE TABLE custom_design (
    Custome_design_id             INT AUTO_INCREMENT PRIMARY KEY,
    player_name    VARCHAR(50),
    jersey_number  VARCHAR(5),
    artwork_url    TEXT,
    order_item_id  INT NOT NULL UNIQUE,

    FOREIGN KEY (order_item_id) REFERENCES order_item(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE payment (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    order_id  INT NOT NULL,
    method    VARCHAR(30) NOT NULL,
    amount    DECIMAL(10,2) NOT NULL,
    status    VARCHAR(20) NOT NULL DEFAULT 'pending',
    FOREIGN KEY (order_id) REFERENCES orders(id)
) ENGINE=InnoDB;

-- Seed the six product categories
INSERT INTO category (name, is_customisable) VALUES
    ('Shirts', FALSE),
    ('Jackets', FALSE),
    ('Socks', FALSE),
    ('Caps', FALSE),
    ('Cargo Pants', FALSE),
    ('Customised Jersey', TRUE);

-- Example product with variants
INSERT INTO product (category_id, name, description, base_price)
VALUES (1, 'Oversized Graphic Tee', 'Heavyweight cotton', 35.00);

INSERT INTO variant (product_id, sku, size, color, stock_qty) VALUES
    (1, 'TEE-001-BLK-M', 'M', 'Black', 25),
    (1, 'TEE-001-BLK-L', 'L', 'Black', 30);

-- Products as a JSON array with nested variants
SELECT p.id,
       c.name AS category,
       p.name,
       p.base_price,
       c.is_customisable,
       JSON_ARRAYAGG(
         JSON_OBJECT('id', v.id, 'sku', v.sku, 'size', v.size,
                     'color', v.color, 'stock_qty', v.stock_qty)
       ) AS variants
FROM product p
JOIN category c ON c.id = p.category_id
JOIN variant v  ON v.product_id = p.id
GROUP BY p.id, c.name, p.name, p.base_price, c.is_customisable;
