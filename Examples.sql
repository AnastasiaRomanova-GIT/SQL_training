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


/*Вывести в алфавитном порядке всех авторов, которые пишут только в одном жанре. Поскольку у нас в таблицах так занесены данные, что у каждого автора книги только в одном жанре,  для этого запроса внесем изменения в таблицу book. Пусть у нас  книга Есенина «Черный человек» относится к жанру «Роман», а книга Булгакова «Белая гвардия» к «Приключениям» (эти изменения в таблицы уже внесены).*/
SELECT name_author
FROM book INNER JOIN author
    ON book.author_id = author.author_id
GROUP BY name_author
HAVING COUNT(DISTINCT genre_id) = 1
ORDER BY name_author