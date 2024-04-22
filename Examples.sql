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

/* Занести для книги «Стихотворения и поэмы» Лермонтова жанр «Поэзия», а для книги «Остров сокровищ» Стивенсона - «Приключения». (Использовать два запроса).*/
UPDATE book
SET genre_id = 
      (
       SELECT genre_id 
       FROM genre 
       WHERE name_genre = 'Поэзия'
      )
WHERE title = 'Стихотворения и поэмы' AND author_id = 5;

UPDATE book
SET genre_id = 
      (
       SELECT genre_id 
       FROM genre 
       WHERE name_genre = 'Приключения'
      )
WHERE title = 'Остров сокровищ' AND author_id = 6;


SELECT * FROM book;

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

/*Удалить все жанры, к которым относится меньше 4-х наименований книг. В таблице book для этих жанров установить значение Null.*/
DELETE
FROM genre 
WHERE genre_id IN 
                    (SELECT genre_id
                    FROM book 
                    GROUP BY genre_id
                    HAVING COUNT(DISTINCT book_id) < 4
                    );

SELECT * FROM genre;

SELECT * FROM book;



/*Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и в каком количестве он заказал) в отсортированном по номеру заказа и названиям книг виде.*/
SELECT DISTINCT buy.buy_id, book.title, book.price, buy_book.amount
FROM 
    client 
    INNER JOIN buy ON client.client_id = buy.client_id
    INNER JOIN buy_book ON buy_book.buy_id = buy.buy_id
    INNER JOIN book ON buy_book.book_id=book.book_id
WHERE name_client ='Баранов Павел'
ORDER BY buy.buy_id, book.title; 

/*Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. Указать количество заказов в каждый город, этот столбец назвать Количество. Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке по названию городов.*/
SELECT city.name_city, COUNT(DISTINCT buy.buy_id) AS Количество
FROM city
    INNER JOIN client ON city.city_id = client.city_id
    INNER JOIN buy ON client.client_id = buy.client_id
GROUP BY city.city_id 
ORDER BY Количество DESC, city.name_city; 

/*Вывести номера всех оплаченных заказов и даты, когда они были оплачены.*/
SELECT buy_id, date_step_end
FROM buy_step
    INNER JOIN step ON buy_step.step_id = step.step_id
WHERE buy_step.step_id = 1 AND buy_step.date_step_end IS NOT NULL 


/*Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора (нужно посчитать, в каком количестве заказов фигурирует каждая книга).  Вывести фамилию и инициалы автора, название книги, последний столбец назвать Количество. Результат отсортировать сначала  по фамилиям авторов, а потом по названиям книг.*/
SELECT author.name_author, book.title, COUNT(buy_book.amount) AS Количество
FROM book
    INNER JOIN author ON book.author_id = author.author_id
    LEFT JOIN buy_book ON buy_book.book_id = book.book_id
GROUP BY author.name_author, book.title, buy_book.book_id
ORDER BY author.name_author, book.title

/*Выбрать всех клиентов, которые заказывали книги Достоевского, информацию вывести в отсортированном по алфавиту виде. В решении используйте фамилию автора, а не его id.*/
SELECT name_client
FROM client
    INNER JOIN buy ON client.client_id = buy.client_id
    INNER JOIN buy_book ON buy.buy_id = buy_book.buy_id
    INNER JOIN book ON buy_book.book_id = book.book_id
    INNER JOIN author ON book.author_id = author.author_id
WHERE author.name_author LIKE "%Достоевский%"
GROUP BY client.name_client
ORDER BY client.name_client


/*Вывести информацию о каждом заказе: его номер, кто его сформировал (фамилия пользователя) и его стоимость (сумма произведений количества заказанных книг и их цены), в отсортированном по номеру заказа виде. Последний столбец назвать Стоимость.*/
SELECT buy_book.buy_id, name_client, SUM(buy_book.amount * book.price) AS Стоимость
FROM book
    INNER JOIN buy_book ON book.book_id = buy_book.book_id
    INNER JOIN buy ON buy.buy_id = buy_book.buy_id
    INNER JOIN client ON buy.client_id = client.client_id
GROUP BY buy_book.buy_id
ORDER BY buy_id 

/*В таблице city для каждого города указано количество дней, за которые заказ может быть доставлен в этот город (рассматривается только этап "Транспортировка"). Для тех заказов, которые прошли этап транспортировки, вывести количество дней за которое заказ реально доставлен в город. А также, если заказ доставлен с опозданием, указать количество дней задержки, в противном случае вывести 0. В результат включить номер заказа (buy_id), а также вычисляемые столбцы Количество_дней и Опоздание. Информацию вывести в отсортированном по номеру заказа виде*/
SELECT buy_step.buy_id, DATEDIFF(buy_step.date_step_end, buy_step.date_step_beg) AS Количество_дней,         IF(DATEDIFF(buy_step.date_step_end, buy_step.date_step_beg) >= city.days_delivery, DATEDIFF(buy_step.date_step_end, buy_step.date_step_beg) - city.days_delivery, 0) AS Опоздание
FROM buy_step 
    INNER JOIN step ON buy_step.step_id = step.step_id
    INNER JOIN buy ON buy_step.buy_id = buy.buy_id
    INNER JOIN client ON buy.client_id = client.client_id
    INNER JOIN city ON client.city_id = city.city_id
WHERE step.name_step = "Транспортировка" AND buy_step.date_step_beg IS NOT NULL AND buy_step.date_step_end IS NOT NULL
ORDER BY buy_step.buy_id


/*Включить нового человека в таблицу с клиентами. Его имя Попов Илья, его email popov@test, проживает он в Москве.*/
INSERT INTO client (name_client, city_id, email)
SELECT 'Попов Илья', city_id, 'popov@test'
FROM city 
WHERE name_city LIKE '%осква'
;
SELECT * FROM client
;

/*Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки».
Важно! В решении нельзя использоваться VALUES и делать отбор по client_id*/
INSERT INTO buy (buy_description, client_id)
SELECT 'Связаться со мной по вопросу доставки', client_id
FROM client 
WHERE name_client = "Попов Илья"
;
SELECT * FROM buy

/*В таблицу buy_book добавить заказ с номером 5. Этот заказ должен содержать книгу Пастернака «Лирика» в количестве двух экземпляров и книгу Булгакова «Белая гвардия» в одном экземпляре.*/
INSERT INTO buy_book (buy_id, book_id, amount)
(
    SELECT '5', book.book_id, '2'
    FROM book 
        INNER JOIN author ON book.author_id = author.author_id
    WHERE book.title = "Лирика" AND author.name_author LIKE "%Пастернак%"

    UNION

    SELECT '5', book.book_id, '1'
    FROM book 
        INNER JOIN author ON book.author_id = author.author_id
    WHERE book.title = "Белая гвардия" AND author.name_author LIKE "%Булгаков%"
);

SELECT * FROM buy_book;

/*Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. Для этого вывести год, месяц, сумму выручки в отсортированном сначала по возрастанию месяцев, затем по возрастанию лет виде. Название столбцов: Год, Месяц, Сумма.*/
SELECT YEAR(buy_step.date_step_end) AS Год, MONTHNAME(buy_step.date_step_end) AS Месяц, SUM(buy_book.amount * book.price) AS Сумма
FROM buy_step
    INNER JOIN buy_book ON buy_step.buy_id = buy_book.buy_id
    INNER JOIN book ON buy_book.book_id = book.book_id
WHERE buy_step.step_id = 1 AND buy_step.date_step_end IS NOT NULL
GROUP BY Год, Месяц

UNION 

SELECT YEAR(date_payment) AS Год, MONTHNAME(date_payment) AS Месяц, SUM(amount * price) AS Сумма
FROM buy_archive
GROUP BY Год, Месяц

ORDER BY Месяц, Год


/*Включить нового человека в таблицу с клиентами. Его имя Попов Илья, его email popov@test, проживает он в Москве.*/
INSERT INTO client (name_client, city_id, email)
SELECT 'Попов Илья', city_id, 'popov@test'
FROM city 
WHERE name_city LIKE '%осква'
;
SELECT * FROM client
;

/*Уменьшить количество тех книг на складе, которые были включены в заказ с номером 5.*/
UPDATE book
    INNER JOIN buy_book ON book.book_id = buy_book.book_id
SET book.amount = book.amount - buy_book.amount
WHERE buy_book.buy_id = 5
;

SELECT * FROM book

/*Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5. Куда включить номер заказа, количество книг в заказе (название столбца Количество) и его общую стоимость (название столбца Итого).  Для решения используйте ОДИН запрос./*
CREATE TABLE buy_pay AS
    SELECT buy_book.buy_id, SUM(buy_book.amount) AS Количество, SUM(buy_book.amount * book.price) AS Итого
    FROM book
        INNER JOIN buy_book ON book.book_id = buy_book.book_id
    WHERE buy_book.buy_id = 5
    GROUP BY buy_book.buy_id
    ;

SELECT * FROM buy_pay


/*Если студент совершал несколько попыток по одной и той же дисциплине, то вывести разницу в днях между первой и последней попыткой. В результат включить фамилию и имя студента, название дисциплины и вычисляемый столбец Интервал. Информацию вывести по возрастанию разницы. Студентов, сделавших одну попытку по дисциплине, не учитывать. */
SELECT student.name_student, subject.name_subject,  DATEDIFF(MAX(date_attempt), MIN(date_attempt)) AS Интервал
FROM student 
    INNER JOIN attempt ON student.student_id = attempt.student_id
    INNER JOIN subject ON attempt.subject_id = subject.subject_id
GROUP BY student.name_student, subject.name_subject
HAVING (MAX(date_attempt) - MIN(date_attempt)) <> 0
ORDER BY Интервал
;


/*Студенты могут тестироваться по одной или нескольким дисциплинам (не обязательно по всем). Вывести дисциплину и количество уникальных студентов (столбец назвать Количество), которые по ней проходили тестирование . Информацию отсортировать сначала по убыванию количества, а потом по названию дисциплины. В результат включить и дисциплины, тестирование по которым студенты не проходили, в этом случае указать количество студентов 0.*/
SELECT DISTINCT subject.name_subject, COUNT(DISTINCT (attempt.student_id)) AS Количество
FROM subject
    LEFT JOIN attempt ON subject.subject_id = attempt.subject_id
GROUP BY subject.name_subject
ORDER BY Количество DESC

/*Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных». В результат включите столбцы question_id и name_question.*/
SELECT question.question_id, question.name_question
FROM question 
    INNER JOIN subject ON question.subject_id = subject.subject_id
WHERE subject.name_subject = "Основы баз данных"
ORDER BY RAND()
LIMIT 3

/*Для каждого вопроса вывести процент успешных решений, то есть отношение количества верных ответов к общему количеству ответов, значение округлить до 2-х знаков после запятой. Также вывести название предмета, к которому относится вопрос, и общее количество ответов на этот вопрос. В результат включить название дисциплины, вопросы по ней (столбец назвать Вопрос), а также два вычисляемых столбца Всего_ответов и Успешность. Информацию отсортировать сначала по названию дисциплины, потом по убыванию успешности, а потом по тексту вопроса в алфавитном порядке.

Поскольку тексты вопросов могут быть длинными, обрезать их 30 символов и добавить многоточие "...".*/
SELECT 
    subject.name_subject, 
    CONCAT(LEFT(question.name_question, 30), "...") AS Вопрос, 
    COUNT(answer.question_id) AS Всего_ответов, 
    ROUND(100 * (SUM(answer.is_correct) / COUNT(answer.question_id)), 2) AS Успешность
FROM answer
    INNER JOIN testing ON answer.answer_id = testing.answer_id
    INNER JOIN attempt ON testing.attempt_id = attempt.attempt_id
    INNER JOIN subject ON attempt.subject_id = subject.subject_id     
    INNER JOIN student ON attempt.student_id = student.student_id
    INNER JOIN question ON testing.question_id = question.question_id
GROUP BY subject.name_subject, question.name_question
ORDER BY subject.name_subject ASC, Успешность DESC, Вопрос ASC;
