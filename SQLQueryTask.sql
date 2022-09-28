/*1. ������ ��� ������ ������ � ������� ���� ������� � ������ X (������ ���� �� �������)*/

USE banking
SELECT DISTINCT bank.name 
FROM bank
	JOIN branch on bank.id = id_bank
	JOIN city on id_city = city.id
WHERE city.name = 'Hrodno'

/*2. �������� ������ �������� � ��������� ����� ���������, ������� � �������� �����*/

SELECT client.firstName, client.lastName, number, card.balance, bank.name 
FROM card
	JOIN account on account.id = id_account
	JOIN bank on bank.id = id_bank
	JOIN client on client.id = id_client

/*3. �������� ������ ���������� ��������� � ������� ������ �� ��������� � ������ ������� �� ���������.
	 � ��������� ������� ������� �������*/

SELECT payslip,
	   account.balance,
	   (SUM(card.balance)) as summary,
	   (account.balance - SUM(card.balance)) AS difference
FROM account
	JOIN card ON id_account = account.id
GROUP BY payslip, account.balance
HAVING account.balance > SUM(card.balance)

/*4. ������� ���-�� ���������� �������� ��� ������� ��� ������� (2 ����������, GROUP BY � �����������)*/

/*GROUP BY*/
use banking
SELECT status.name,
	   COUNT(card.id) as card_count
FROM status
	JOIN client on id_status = status.id
	JOIN account on id_client = client.id
	JOIN card on id_account = account.id
GROUP BY status.name

/*���������*/
USE banking
SELECT status.name,
	   (SELECT COUNT(card.id)
	   FROM card, account, client 
	   WHERE id_account = account.id 
		   and id_client = client.id
		   and id_status = status.id) as countAc
FROM status

/*5. �������� stored procedure ������� ����� ��������� �� 10$ �� ������ ���������� ������� ��� ������������� ��� �������
	 (� ������� ������� ������ ������ ���. �������. ��������, ���������, ������� � ������).
	 ������� �������� ��������� - Id ����������� �������. 
	 ���������� �������������� �������� (��������, ��� ������ �������� ����� ���. �������.
	 ���� ����� � ����� ������� ��� ����������� ���������).*/


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


/*6. �������� ������ ��������� ������� ��� ������� �������.
	 �� ���� ���� � ������� �� ���������� �������� 60 ������,
	 � � ���� 2 �������� �� 15 ������ �� ������, �� � ���� �������� 30 ������ ��� �������� �� ����� �� ����*/

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

/*��� ���� �������� ��������� 5 � ���������� �������*/

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

/*7. �������� ��������� ������� ����� ���������� ����������� ����� �� ����� �� ����� ����� ��������.
	 ��� ���� ����� ������� ��� ������ �� ����� ��� ����� ���������, ������ ����� ������� �� ����� ����������.
	 ��������, � ���� ���� ������� �� ������� 1000 ������ � ��� ����� �� 300 ������ �� ������.
	 � ���� ��������� 200 ������ �� ���� �� ����, ��� ���� ������ �������� ��������� 1000 ������,
	 � �� ������ ����� ����� 300 � 500 ������ ��������������. ����� ����� � ��� �� ����� ��������� 400 ������ � �������� �� �� ���� �� ����,
	 ��� ��� ��������� ����� 200 ��������� ������ (1000-300-500). ���������� ���������. �� ���� ������������ ����������*/


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

/*��������*/

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

/*8. �������� ������� �� ������� Account/Cards ����� ������ ���� ������� �������� � ���� ������ ���� ��� ������������ ��������
	 (�� ���� ������ �������� �������� � Account �� �������, ��� ����� �������� �� ���� ���������.
	 � �������������� ������ �������� ������ ����� ���� � ����� ����� �� ������ ����� ������ ��� ������ ��������)*/


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
