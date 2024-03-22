SELECT author, title, 
    ROUND(IF(author = "Булгаков М.А.", price * 1.1, IF(author = "Есенин С.А.", price *1.05, price * 1)), 2) AS new_price
FROM book;

/* Для каждой книги из таблицы book установим скидку следующим образом: если количество книг меньше 4, то скидка будет составлять 50% от цены, в противном случае 30%.*/
SELECT title, amount, price, 
    IF(amount<4, price*0.5, price*0.7) AS sale
FROM book;

/*Посчитать, количество различных книг и количество экземпляров книг каждого автора , хранящихся на складе.  Столбцы назвать Автор, Различных_книг и Количество_экземпляров соответственно.*/
SELECT author AS Автор, 
	COUNT(title) AS Различных_книг, 
	SUM(amount) AS Количество_экземпляров
FROM book
GROUP BY author

/*Посчитать стоимость всех экземпляров каждого автора без учета книг «Идиот» и «Белая гвардия». В результат включить только тех авторов, у которых суммарная стоимость книг (без учета книг «Идиот» и «Белая гвардия») более 5000 руб. Вычисляемый столбец назвать Стоимость. Результат отсортировать по убыванию стоимости.*/
SELECT author, 
    ROUND(SUM(price*amount), 2) AS Стоимость
FROM book
WHERE title NOT IN ("Идиот", "Белая гвардия")
GROUP BY author
HAVING SUM(amount * price) > 5000
ORDER BY SUM(amount * price) DESC

/*Вывести информацию (автора, название и цену) о  книгах, цены которых меньше или равны средней цене книг на складе. Информацию вывести в отсортированном по убыванию цены виде. Среднее вычислить как среднее по цене книги.*/
SELECT author, title, price
FROM book
WHERE price <= (
    SELECT AVG(price)
    FROM book)
ORDER BY price DESC

/*Посчитать сколько и каких экземпляров книг нужно заказать поставщикам, чтобы всех книг на складе стало столько, сколько сейчас есть экземлпяров самой широкопредставленной книги. Вывести название книги, ее автора, текущее количество экземпляров на складе и количество заказываемых экземпляров книг. Последнему столбцу присвоить имя Заказ. В результат не включать книги, которые заказывать не нужно.*/
SELECT title, 
    author, 
    amount, 
    (SELECT MAX(amount) FROM book) - amount AS Заказ 
FROM book
HAVING Заказ > 0

/*Create a table*/
CREATE TABLE book(
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author VARCHAR(30),
    price DECIMAL(8, 2),
    amount INT
);

/*Вывести информацию (автора, книгу и количество) о тех книгах, количество экземпляров которых в таблице book не дублируется.*/
SELECT author, title, amount
FROM book
WHERE amount IN (
    SELECT amount
    FROM book 
    GROUP BY amount
    HAVING COUNT(amount) = 1
                )

/* Вывести фамилию с инициалами и общую сумму суточных, полученных за все командировки для тех сотрудников, которые были в командировках больше чем 3 раза, в отсортированном по убыванию сумм суточных виде. Последний столбец назвать Сумма.*/
SELECT name, SUM((1 + DATEDIFF(date_last, date_first)) * per_diem) AS Сумма
FROM trip
GROUP BY name
HAVING COUNT(DISTINCT trip_id) > 3
ORDER BY Сумма DESC

/*В таблице fine увеличить в два раза сумму неоплаченных штрафов для отобранных слкдующим образом записей. Вывести фамилию, номер машины и нарушение только для тех водителей, которые на одной машине нарушили одно и то же правило   два и более раз. При этом учитывать все нарушения, независимо от того оплачены они или нет. Информацию отсортировать в алфавитном порядке, сначала по фамилии водителя, потом по номеру машины и, наконец, по нарушению. 
*/  
UPDATE fine, (
                SELECT name, number_plate, violation
                FROM fine
                GROUP BY name, number_plate, violation
                HAVING count(violation) >= 2
                ORDER BY name, number_plate, violation
               ) query_in
SET sum_fine = sum_fine*2
WHERE 
    date_payment is null AND
    fine.name = query_in.name AND
    fine.number_plate = query_in.number_plate AND
    fine.violation = query_in.violation
;

SELECT * 
FROM fine

/*Создать таблицу author следующей структуры:

Поле	Тип, описание
author_id	INT PRIMARY KEY AUTO_INCREMENT
name_author	VARCHAR(50)*/
CREATE TABLE author (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name_author VARCHAR(50)
                    )
;

/*Заполнить таблицу author. В нее включить следующих авторов:

Булгаков М.А.
Достоевский Ф.М.
Есенин С.А.
Пастернак Б.Л.*/
INSERT INTO author(author_id, name_author)
VALUES (1, 'Булгаков М.А.'),
        (2, 'Достоевский Ф.М.'),
        (3, 'Есенин С.А.'),
        (4, 'Пастернак Б.Л.');
        
SELECT * FROM author
;

CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT, 
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id),
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id) 
                    );
                    
SHOW COLUMNS FROM book;

/*Задание
Создать таблицу book той же структуры, что и на предыдущем шаге. Будем считать, что при удалении автора из таблицы author, должны удаляться все записи о книгах из таблицы book, написанные этим автором. А при удалении жанра из таблицы genre для соответствующей записи book установить значение Null в столбце genre_id. */
CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT, 
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id) ON DELETE SET NULL
                    );
                    
SHOW COLUMNS FROM book;  

INSERT INTO book(book_id, title, author_id, genre_id, price, amount)
VALUES (6, 'Стихотворения и поэмы', 3, 2, 650.00, 15),
        (7, 'Черный человек', 3, 2, 570.20, 6),
        (8, 'Лирика', 4, 2, 518.99, 2);
        
SELECT * FROM book

/*Задание
Вывести название, жанр и цену тех книг, количество которых больше 8, в отсортированном по убыванию цены виде.*/
SELECT title, name_genre, price
FROM 
    genre INNER JOIN book
    ON genre.genre_id = book.genre_id
WHERE book.amount > 8
ORDER BY price DESC
;

/*Задание
Вывести все жанры, которые не представлены в книгах на складе.

запрос не работает с HAVING потому, что HAVING видит только то, что было выбрано в SELECT и не имеет доступа к целой таблице*/
SELECT name_genre
FROM genre LEFT JOIN book
     ON genre.genre_id = book.genre_id
WHERE title IS NULL
;

/*Необходимо в каждом городе провести выставку книг каждого автора в течение 2020 года. Дату проведения выставки выбрать случайным образом. Создать запрос, который выведет город, автора и дату проведения выставки. Последний столбец назвать Дата. Информацию вывести, отсортировав сначала в алфавитном порядке по названиям городов, а потом по убыванию дат проведения выставок.*/
SELECT name_city, name_author, DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND()*365) DAY) AS Дата
FROM city, author
ORDER BY name_city, Дата DESC

/*Вывести информацию о книгах (жанр, книга, автор), относящихся к жанру, включающему слово «роман» в отсортированном по названиям книг виде.*/
SELECT name_genre, title, name_author
FROM
    genre 
    INNER JOIN book ON genre.genre_id = book.genre_id
    INNER JOIN author ON author.author_id = book.author_id
WHERE name_genre LIKE '%_оман%'
ORDER by title

/*Посчитать количество экземпляров  книг каждого автора из таблицы author.  Вывести тех авторов,  количество книг которых меньше 10, в отсортированном по возрастанию количества виде. Последний столбец назвать Количество.*/
SELECT name_author, SUM(amount) AS Количество
FROM author LEFT JOIN book 
    ON author.author_id = book.author_id
    GROUP BY name_author
    HAVING Количество < 10 OR Количество IS NULL
    ORDER BY Количество


/*Вывести в алфавитном порядке всех авторов, которые пишут только в одном жанре. Поскольку у нас в таблицах так занесены данные, что у каждого автора книги только в одном жанре,  для этого запроса внесем изменения в таблицу book. Пусть у нас  книга Есенина «Черный человек» относится к жанру «Роман», а книга Булгакова «Белая гвардия» к «Приключениям» (эти изменения в таблицы уже внесены).*/
SELECT name_author
FROM book INNER JOIN author
    ON book.author_id = author.author_id
GROUP BY name_author
HAVING COUNT(DISTINCT genre_id) = 1
ORDER BY name_author

/*Вывести информацию о книгах (название книги, фамилию и инициалы автора, название жанра, цену и количество экземпляров книг), написанных в самых популярных жанрах, в отсортированном в алфавитном порядке по названию книг виде. Самым популярным считать жанр, общее количество экземпляров книг которого на складе максимально.*/
SELECT title, name_author, name_genre, price, amount
FROM 
    author 
    INNER JOIN book ON author.author_id = book.author_id
    INNER JOIN genre ON  book.genre_id = genre.genre_id

WHERE genre.genre_id IN
         (SELECT query_in_1.genre_id
          FROM 
              (SELECT genre_id, SUM(amount) AS sum_amount
               FROM book
               GROUP BY genre_id) query_in_1
          INNER JOIN 
              (SELECT genre_id, SUM(amount) AS sum_amount
               FROM book
               GROUP BY genre_id
               ORDER BY sum_amount DESC
               LIMIT 1) query_in_2
          ON query_in_1.sum_amount = query_in_2.sum_amount)

ORDER BY title


/*Если в таблицах supply  и book есть одинаковые книги, которые имеют равную цену,  вывести их название и автора, а также посчитать общее количество экземпляров книг в таблицах supply и book,  столбцы назвать Название, Автор  и Количество.*/
SELECT book.title AS Название, name_author AS Автор, (book.amount + supply.amount) AS Количество
FROM 
    author
    INNER JOIN book USING(author_id)
    INNER JOIN supply ON author.name_author = supply.author
                      AND book.title = supply.title

WHERE book.amount = supply.amount


/*Для книг, которые уже есть на складе (в таблице book), но по другой цене, чем в поставке (supply),  необходимо в таблице book увеличить количество на значение, указанное в поставке,  и пересчитать цену. А в таблице  supply обнулить количество этих книг. Формула для пересчета цены: price_new = (price1*amount1 + price2*amount2)/(amount1 + price 1)*/
UPDATE book 
     INNER JOIN author ON author.author_id = book.author_id
     INNER JOIN supply ON book.title = supply.title 
                         and supply.author = author.name_author
SET book.price = ((book.amount*book.price + supply.amount*supply.price)/(book.amount + supply.amount)),
    book.amount = book.amount + supply.amount,
    supply.amount = 0   
WHERE book.price <> supply.price;

SELECT * FROM book;

SELECT * FROM supply;

/*Включить новых авторов в таблицу author с помощью запроса на добавление, а затем вывести все данные из таблицы author.  Новыми считаются авторы, которые есть в таблице supply, но нет в таблице author.*/
INSERT INTO author(name_author)
SELECT supply.author
FROM 
    author 
    RIGHT JOIN supply on author.name_author = supply.author
WHERE name_author IS Null;

SELECT * FROM author

/*Добавить новые книги из таблицы supply в таблицу book на основе сформированного выше запроса. Затем вывести для просмотра таблицу book.*/
INSERT INTO book (title, author_id, price, amount)
SELECT title, author_id, price, amount
FROM 
    author 
    INNER JOIN supply ON author.name_author = supply.author
WHERE amount <> 0;

SELECT * FROM book

/*Удалить всех авторов и все их книги, общее количество книг которых меньше 20.*/
DELETE FROM author
WHERE author_id IN 
        (SELECT author_id
        FROM book
        GROUP BY author_id
        HAVING SUM(amount) <20
        );

SELECT * FROM author;

SELECT * FROM book;