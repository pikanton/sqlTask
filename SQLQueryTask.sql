/*1. Покажи мне список банков у которых есть филиалы в городе X (выбери один из городов)*/

USE banking
SELECT DISTINCT bank.name 
FROM bank
	JOIN branch on bank.id = id_bank
	JOIN city on id_city = city.id
WHERE city.name = 'Hrodno'

/*2. Получить список карточек с указанием имени владельца, баланса и названия банка*/

SELECT client.firstName, client.lastName, number, card.balance, bank.name 
FROM card
	JOIN account on account.id = id_account
	JOIN bank on bank.id = id_bank
	JOIN client on client.id = id_client

/*3. Показать список банковских аккаунтов у которых баланс не совпадает с суммой баланса по карточкам.
	 В отдельной колонке вывести разницу*/

SELECT payslip,
	   account.balance,
	   (SUM(card.balance)) as summary,
	   (account.balance - SUM(card.balance)) AS difference
FROM account
	JOIN card ON id_account = account.id
GROUP BY payslip, account.balance
HAVING account.balance > SUM(card.balance)

/*4. Вывести кол-во банковских карточек для каждого соц статуса (2 реализации, GROUP BY и подзапросом)*/

/*GROUP BY*/
use banking
SELECT status.name,
	   COUNT(card.id) as card_count
FROM status
	JOIN client on id_status = status.id
	JOIN account on id_client = client.id
	JOIN card on id_account = account.id
GROUP BY status.name

/*Подзапрос*/
USE banking
SELECT status.name,
	   (SELECT COUNT(card.id)
	   FROM card, account, client 
	   WHERE id_account = account.id 
		   and id_client = client.id
		   and id_status = status.id) as countAc
FROM status

/*5. Написать stored procedure которая будет добавлять по 10$ на каждый банковский аккаунт для определенного соц статуса
	 (У каждого клиента бывают разные соц. статусы. Например, пенсионер, инвалид и прочее).
	 Входной параметр процедуры - Id социального статуса. 
	 Обработать исключительные ситуации (например, был введен неверные номер соц. статуса.
	 Либо когда у этого статуса нет привязанных аккаунтов).*/


CREATE PROCEDURE AddMoney
	@id_status INT
AS
BEGIN
	IF NOT EXISTS(SELECT id FROM status WHERE id = @id_status)
		PRINT 'There is no status with this id!'
	ELSE IF NOT EXISTS(SELECT account.id 
					   FROM account,client,status
					   WHERE id_client = client.id
						   and id_status = status.id
						   and status.id = @id_status)
		PRINT 'There is no cards with this status_id!'
	ELSE
	BEGIN
		UPDATE account
		SET balance = balance + 10
		FROM client, status
		WHERE client.id = id_client
			and status.id = id_status
			and status.id = @id_status
	END
END


/*6. Получить список доступных средств для каждого клиента.
	 То есть если у клиента на банковском аккаунте 60 рублей,
	 и у него 2 карточки по 15 рублей на каждой, то у него доступно 30 рублей для перевода на любую из карт*/

SELECT bank.name,
	   firstName,
	   lastName,
	   status.id,
	   payslip,
	   account.balance,
	   (account.balance - SUM(card.balance)) AS difference
	   
FROM account
	JOIN card ON id_account = account.id
	JOIN client ON id_client = client.id
	JOIN bank ON id_bank = bank.id
	JOIN status ON id_status = status.id
GROUP BY bank.name, firstName, lastName, status.id, payslip, account.balance

/*Тут идет проверка процедуры 5 и повторение запроса*/

EXEC AddMoney 5

SELECT bank.name,
	   firstName,
	   lastName,
	   status.id,
	   payslip,
	   account.balance,
	   (account.balance - SUM(card.balance)) AS difference
	   
FROM account
	JOIN card ON id_account = account.id
	JOIN client ON id_client = client.id
	JOIN bank ON id_bank = bank.id
	JOIN status ON id_status = status.id
GROUP BY bank.name, firstName, lastName, status.id, payslip, account.balance

/*7. Написать процедуру которая будет переводить определённую сумму со счёта на карту этого аккаунта.
	 При этом будем считать что деньги на счёту все равно останутся, просто сумма средств на карте увеличится.
	 Например, у меня есть аккаунт на котором 1000 рублей и две карты по 300 рублей на каждой.
	 Я могу перевести 200 рублей на одну из карт, при этом баланс аккаунта останется 1000 рублей,
	 а на картах будут суммы 300 и 500 рублей соответственно. После этого я уже не смогу перевести 400 рублей с аккаунта ни на одну из карт,
	 так как останется всего 200 свободных рублей (1000-300-500). Переводить БЕЗОПАСНО. То есть использовать транзакцию*/


CREATE PROCEDURE TransferMoney
	@id_account INT,
	@id_card INT,
	@money MONEY
AS
BEGIN
	IF NOT EXISTS(SELECT id FROM account WHERE id = @id_account)
		PRINT 'There is no account with this id!'
	ELSE IF NOT EXISTS(SELECT id FROM card WHERE id = @id_card)
		PRINT 'There is no cards with this status_id!'
	ELSE IF @id_card NOT IN (SELECT id FROM card WHERE id_account = @id_account)
		PRINT 'Card does not belong to this account!'
	ELSE
	BEGIN
		BEGIN TRY
			BEGIN TRAN
			UPDATE card
			SET balance = balance + @money
			WHERE id = @id_card
		END TRY
			BEGIN CATCH
				ROLLBACK TRAN
				PRINT 'Error ' + ERROR_NUMBER() + ' ' + ERROR_MESSAGE()
				RETURN
			END CATCH
		COMMIT TRAN
	END
END

/*Проверка*/

SELECT bank.name,
	   firstName,
	   lastName,
	   status.id,
	   payslip,
	   account.balance,
	   (account.balance - SUM(card.balance)) AS difference
	   
FROM account
	JOIN card ON id_account = account.id
	JOIN client ON id_client = client.id
	JOIN bank ON id_bank = bank.id
	JOIN status ON id_status = status.id
GROUP BY bank.name, firstName, lastName, status.id, payslip, account.balance

EXEC TransferMoney 5,1,100

SELECT bank.name,
	   firstName,
	   lastName,
	   status.id,
	   payslip,
	   account.balance,
	   (account.balance - SUM(card.balance)) AS difference
	   
FROM account
	JOIN card ON id_account = account.id
	JOIN client ON id_client = client.id
	JOIN bank ON id_bank = bank.id
	JOIN status ON id_status = status.id
GROUP BY bank.name, firstName, lastName, status.id, payslip, account.balance

/*8. Написать триггер на таблицы Account/Cards чтобы нельзя была занести значения в поле баланс если это противоречит условиям
	 (то есть нельзя изменить значение в Account на меньшее, чем сумма балансов по всем карточкам.
	 И соответственно нельзя изменить баланс карты если в итоге сумма на картах будет больше чем баланс аккаунта)*/


USE banking
GO
CREATE TRIGGER cardUPDATE
	ON card AFTER UPDATE
	AS IF UPDATE(balance)
BEGIN
	DECLARE @accountBalance MONEY
	DECLARE @newCardBalance MONEY
	DECLARE @id_card INT
	DECLARE @id_account INT

	SELECT @id_card = id FROM deleted
	SELECT @id_account = id_account FROM deleted
	SELECT @accountbalance = balance 
	FROM account
	WHERE id = @id_account

	SELECT @newCardBalance = SUM(card.balance)
	FROM card
		JOIN account ON id_account = account.id
	WHERE account.id = @id_account
	IF (@accountbalance < @newCardBalance)
	BEGIN
		
		PRINT 'Not enough money to transfer!!'
		ROLLBACK TRANSACTION
	END
END



USE banking
GO
CREATE TRIGGER accountUPDATE
	ON account AFTER UPDATE
	AS IF UPDATE(balance)
BEGIN
	DECLARE @newAccountBalance MONEY
	DECLARE @cardBalance MONEY
	DECLARE @id_account INT

	SELECT @id_account = id FROM deleted
	SELECT @newAccountBalance = balance FROM inserted

	SELECT @cardBalance = SUM(card.balance)
	FROM card
		JOIN account ON id_account = account.id
	WHERE account.id = @id_account
		
	IF (@newAccountbalance < @cardBalance)
	BEGIN
		PRINT 'Not enough money to transfer!!'
		ROLLBACK TRANSACTION
	END
END
