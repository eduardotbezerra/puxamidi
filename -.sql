SELECT
    w.created_at,
    u.name,
    u.email,
    bf.value,
    bf.date,
    w.paymentDate,
    w.confirmationCode,
    bk.bankName,
    ba.op,
    ba.agency,
    ba.agencyDigit,
    ba.numberAccount,
    ba.numberAccountDigit,
    ba.holderName,
    ba.document,
    ba.typeAccount
FROM balanceFlow bf
  INNER JOIN balanceFlowType bFT on bf.balanceFlowTypeId = bFT.idBalanceFlowType
  INNER JOIN withdraw w on bf.withdrawId = w.idWithdraw
  INNER JOIN balance b on bf.balanceId = b.idBalance
  INNER JOIN driver d on b.idBalance = d.balanceId
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN bankAccount ba on u.bankAccountId = ba.idBankAccount
  INNER JOIN bank bk on ba.bankId = bk.idBank
WHERE bf.balanceId = 310 AND w.paymentDate IS NULL
ORDER BY date DESC;

# corridas finalizadas por mes
SELECT
#   t.driverId,
  COUNT(t.idTrip) AS quantityTrips,
  FORMAT(SUM(t.price), 2, 'de_DE') AS totalPrice,
  DATE_FORMAT(t.date, '%Y-%m-%d') AS day
#   COUNT(t.tripPaymentFormId) AS quantityPaymentForm,
#   u.name
#   tPF.name
FROM trip t
#     INNER JOIN driver d ON t.driverId = d.idDriver
#     INNER JOIN user u ON d.userId = u.idUser
  WHERE
    DATE_FORMAT(t.date, '%Y-%m') = '2019-01'
  GROUP BY day
#   ORDER BY quantityTrips DESC;
ORDER BY day DESC;

SELECT
  *
FROM (
    SELECT
      DATE_FORMAT(t.date, '%Y-%m-%d') AS day,
      COUNT(t.idTrip) AS quantityTrips,
      FORMAT(SUM(t.price), 2, 'de_DE') AS totalPrice,
      IFNULL(f.quantityTripsFinished, 0) AS quantityTripsFinished,
      IFNULL(f.totalPriceFinished, 0) AS totalPriceFinished,
      IFNULL(na.quantityTripsNotAnswered, 0) AS quantityTripsNotAnswered,
      IFNULL(na.totalPriceNotAnswered, 0) AS totalPriceNotAnswered,
      IFNULL(bo.quantityTripsBackOff, 0) AS quantityTripsBackOff,
      IFNULL(bo.totalPriceBackOff, 0) AS totalPriceBackOff,
      IFNULL(nat.quantityTripsNotAttended, 0) AS quantityTripsNotAttended,
      IFNULL(nat.totalPriceNotAttended, 0) AS totalPriceNotAttended,
      IFNULL(c.quantityTripsCanceled, 0) AS quantityTripsCanceled,
      IFNULL(c.totalPriceCanceled, 0) AS totalPriceCanceled
    FROM trip t
      LEFT JOIN (SELECT
          COUNT(t.idTrip) AS quantityTripsFinished,
          FORMAT(SUM(t.price), 2, 'de_DE') AS totalPriceFinished,
          DATE_FORMAT(t.date, '%Y-%m-%d') AS day
        FROM trip t
          WHERE t.status = 'finished' GROUP BY day) f ON f.day = DATE_FORMAT(t.date, '%Y-%m-%d')
      LEFT JOIN (SELECT
          COUNT(t.idTrip) AS quantityTripsNotAnswered,
          FORMAT(SUM(t.price), 2, 'de_DE') AS totalPriceNotAnswered,
          DATE_FORMAT(t.date, '%Y-%m-%d') AS day
        FROM trip t
          WHERE
             t.status = 'not_answered' OR
             t.status = 'back_off' OR
             (t.status = 'canceled' AND t.driverId IS NULL)
           GROUP BY day) na ON na.day = DATE_FORMAT(t.date, '%Y-%m-%d')
      LEFT JOIN (SELECT
          COUNT(t.idTrip) AS quantityTripsBackOff,
          FORMAT(SUM(t.price), 2, 'de_DE') AS totalPriceBackOff,
          DATE_FORMAT(t.date, '%Y-%m-%d') AS day
        FROM trip t
          WHERE
             t.status = 'back_off' AND t.driverId IS NULL
           GROUP BY day) bo ON bo.day = DATE_FORMAT(t.date, '%Y-%m-%d')
      LEFT JOIN (SELECT
          COUNT(t.idTrip) AS quantityTripsNotAttended,
          FORMAT(SUM(t.price), 2, 'de_DE') AS totalPriceNotAttended,
          DATE_FORMAT(t.date, '%Y-%m-%d') AS day
        FROM trip t
          WHERE
             t.status = 'not_answered' AND t.driverId IS NULL
           GROUP BY day) nat ON nat.day = DATE_FORMAT(t.date, '%Y-%m-%d')
      LEFT JOIN (SELECT
          COUNT(t.idTrip) AS quantityTripsCanceled,
          FORMAT(SUM(t.price), 2, 'de_DE') AS totalPriceCanceled,
          DATE_FORMAT(t.date, '%Y-%m-%d') AS day
        FROM trip t
          WHERE
             t.status = 'canceled' AND t.driverId IS NOT NULL
           GROUP BY day) c ON c.day = DATE_FORMAT(t.date, '%Y-%m-%d')
      GROUP BY day ORDER BY day DESC
) AS trip_counters_by_day;

# corridas canceladas por mes
SELECT
  t.driverId,
  t.canceledBy,
  COUNT(t.canceledBy) AS totalCanceledBy,
  u.name AS driverName,
  tu.name AS partner
FROM trip t
	  LEFT JOIN driver d ON t.driverId = d.idDriver
    LEFT JOIN user u ON d.userId = u.idUser
    LEFT JOIN user tu ON tu.idUser = t.userId
    INNER JOIN tripPaymentForm tPF ON t.tripPaymentFormId = tPF.idTripPaymentForm
	WHERE
    t.status = 'canceled' AND
    t.driverId IS NOT NULL AND
    DATE_FORMAT(t.date, '%Y-%m') = '2018-11'
  GROUP BY driverName, canceledBy
ORDER BY totalCanceledBy DESC;

SELECT
	SUM(t.price)
FROM trip t
	WHERE tripPaymentFormId = 1 AND
    status = 'finished' AND
    DATE_FORMAT(t.date, '%Y-%m') = '2018-11';

SELECT
	SUM(t.price)
FROM trip t
	WHERE tripPaymentFormId = 2 AND
    status = 'finished' AND
    DATE_FORMAT(t.date, '%Y-%m') = '2018-11';

# Chamada de motoristas (quantidade)
SELECT
	COUNT(t.driverId) AS quantity,
  u.name
FROM tripHistory t
	INNER JOIN driver d ON t.driverId = d.idDriver
  INNER JOIN user u ON d.userId = u.idUser
WHERE DATE_FORMAT(t.date, '%Y-%m') = '2019-01'
GROUP BY t.driverId ORDER BY quantity DESC;

SELECT
	t.date,
  u.name,
  p.alias
FROM trip t
  INNER JOIN user u ON t.userId = u.idUser
  INNER JOIN customer c ON c.userId = u.idUser
  INNER JOIN places p ON c.placeId = p.idPlace
WHERE DATE_FORMAT(t.date, '%Y-%m') = '2018-10'
GROUP BY t.userId ORDER BY date DESC;

# quantidade de parceiros ativos
SELECT
	COUNT(*)
FROM user u
	INNER JOIN levelAccess la ON la.userId = u.idUser
	INNER JOIN customer c ON c.userId = u.idUser
    INNER JOIN places p ON c.placeId = p.idPlace
    INNER JOIN userType ut ON la.userTypeId = ut.idUserType
WHERE la.userTypeId = 6
  AND DATE_FORMAT(u.created_at, '%Y-%m') = '2018-10'
	AND email <> 'eduardoroseo@gmail.com'
  AND email <> 'alinekies@gmail.com'
  AND email <> 'teste.teste2@gmail.com'
  AND email <> 'leticia19costa@outlook.com'
  AND email <> 'paullosergio40@hotmail.com';

SELECT
	u.name,
    p.alias
FROM user u
	INNER JOIN levelAccess la ON la.userId = u.idUser
	INNER JOIN customer c ON c.userId = u.idUser
    INNER JOIN places p ON c.placeId = p.idPlace
    INNER JOIN userType ut ON la.userTypeId = ut.idUserType
WHERE la.userTypeId = 6
  AND DATE_FORMAT(u.created_at, '%Y-%m') = '2018-10'
	AND email <> 'eduardoroseo@gmail.com'
  AND email <> 'alinekies@gmail.com'
  AND email <> 'teste.teste2@gmail.com'
  AND email <> 'leticia19costa@outlook.com'
  AND email <> 'paullosergio40@hotmail.com';

# quantidade de motoristas
SELECT
  *
FROM user u
#   INNER JOIN driver d on u.idUser = d.userId
WHERE u.idUser = *;

# buscar conta bancaria
SELECT
  *
FROM bankAccount ba
  INNER JOIN bank b on ba.bankId = b.idBank
  WHERE ba.idBankAccount = 611;

SELECT
  *
FROM tripHistory
  WHERE driverId = 66;

# consultar corridas bloqueadas
SELECT
  bf.idBalanceFlow,
  bFT.idBalanceFlowType,
  bFT.name,
  t.price,
  bf.value,
  bFT.flow,
  t.driverId,
  u.name AS driverName,
  bf.date,
  t.tripReference
FROM trip t
  INNER JOIN balanceFlow bf ON t.tripReference = bf.tripReference
  INNER JOIN balanceFlowType bFT on bf.balanceFlowTypeId = bFT.idBalanceFlowType
  INNER JOIN driver d ON t.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
WHERE (bFT.flowId = 3 OR bFT.flowId = 4) AND bf.balanceId = 315
  ORDER BY bf.date DESC;

SELECT
  d.idDriver,
  u.name,
  d.status,
  d.appIsOpen,
  d.appVersion,
  b.balance,
  b.blockedBalance
FROM driver d
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN balance b on d.balanceId = b.idBalance
  LEFT JOIN station s ON d.stationId = s.idStation
# WHERE d.idDriver = 229;
WHERE la.userTypeId = 8;

# Financeiro do motorista pelo id do saldo ou id do motorista
SELECT
  bf.idBalanceFlow,
  bFT.idBalanceFlowType,
  bf.date,
  bFT.name,
#   FORMAT(t.price, 2, 'de_DE'),
  FORMAT(bf.value, 2, 'de_DE'),
  bFT.flow,
  u.name AS driverName,
  t.driverId,
  t.tripReference
FROM balanceFlow bf
  LEFT JOIN trip t ON t.tripReference = bf.tripReference
  LEFT JOIN balanceFlowType bFT on bf.balanceFlowTypeId = bFT.idBalanceFlowType
  LEFT JOIN driver d ON bf.balanceId = d.balanceId
  LEFT JOIN user u on d.userId = u.idUser
# WHERE bf.balanceId = 418
WHERE d.idDriver = 276
  ORDER BY bf.date DESC;

SELECT
  *
FROM balanceFlow
  WHERE idBalanceFlow = 15706;

SELECT
  *
FROM balance b
  WHERE b.idBalance = 477;

SELECT
  b.balance,
  u.name,
  u.email
FROM balance b
  INNER JOIN driver d on b.idBalance = d.balanceId
  INNER JOIN user u on d.userId = u.idUser
  WHERE idBalance = 477;

# buscando financeiro de uma corrida
SELECT
  bf.idBalanceFlow,
  bFT.idBalanceFlowType,
  bFT.name,
  t.price,
  bf.value,
  bFT.flow,
  t.driverId,
  bf.balanceId,
  u.name AS driverName,
  bf.date
FROM trip t
  INNER JOIN balanceFlow bf ON t.tripReference = bf.tripReference
  INNER JOIN balanceFlowType bFT on bf.balanceFlowTypeId = bFT.idBalanceFlowType
  INNER JOIN driver d ON t.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
WHERE t.tripReference = '50499732-e110-e574-30c8-8324ba67d342'
  ORDER BY bf.date DESC;

SELECT
  bf.idBalanceFlow,
  bFT.idBalanceFlowType,
  bFT.flowId,
  bFT.name,
  t.price,
  bf.value,
  bFT.flow,
  t.driverId,
  u.name AS driverName,
  bf.date,
  bf.tripReference
FROM balanceFlow bf
  INNER JOIN trip t ON t.tripReference = bf.tripReference
  INNER JOIN balanceFlowType bFT on bf.balanceFlowTypeId = bFT.idBalanceFlowType
  INNER JOIN driver d ON t.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
WHERE (bFT.flowId = 3 OR bFT.flowId = 4) AND bf.balanceId = 327
  ORDER BY bf.date DESC;

SELECT
  *
FROM balance b
  WHERE b.idBalance = 378;

# Liberar corridas bloqueadas
# UPDATE balanceFlow SET balanceFlowTypeId = 9
# WHERE
#     idBalanceFlow = 3594 OR
#     idBalanceFlow = 3591 OR
#     idBalanceFlow = 3588 OR
#     idBalanceFlow = 3583 OR
#     idBalanceFlow = 3579 OR
#     idBalanceFlow = 3576 OR
#     idBalanceFlow = 3570 OR
#     idBalanceFlow = 3556 OR
#     idBalanceFlow = 3554 OR
#     idBalanceFlow = 3550 OR
#     idBalanceFlow = 3533 OR
#     idBalanceFlow = 3530 OR
#     idBalanceFlow = 3522 OR
#     idBalanceFlow = 3519

# total de corridas finalizadas + total de comissao motorista
SELECT
  COUNT(t.tripReference) AS quantidade,
  SUM(t.price) AS valorTotalEmCorridas,
  SUM(bf.value) AS totalComissaoMotorista,
  u.name
FROM trip t
  INNER JOIN driver d ON t.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN balanceFlow bf ON bf.tripReference = t.tripReference AND d.balanceId = bf.balanceId
  INNER JOIN balanceFlowType bft ON bf.balanceFlowTypeId = bft.idBalanceFlowType
WHERE t.status = 'finished' AND bft.reference = 3 AND bft.flow = 'entrada'
  GROUP BY t.driverId
  ORDER BY quantidade DESC;

# motorista que tocou chamado e recusaram
SELECT
    COUNT(driverId) AS quantityDriver,
    u.name
FROM tripHistory
  INNER JOIN driver d on tripHistory.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
WHERE tripHistory.status = 'denied'
GROUP BY driverId ORDER BY quantityDriver DESC;

# corridas acontecendo
SELECT
  u.name,
  u.phone,
  t.*
FROM trip t
  INNER JOIN driver d ON t.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
  WHERE t.status <> 'canceled' AND t.status <> 'finished';

# todas as corridas
SELECT
  t.tripReference,
  ud.name,
  u.name,
  t.date,
  t.endDate,
  t.price,
  t.status
FROM trip t
  INNER JOIN driver d ON d.idDriver = t.driverId
  INNER JOIN user ud on d.userId = ud.idUser
  INNER JOIN user u on t.userId = u.idUser
  ORDER BY t.date DESC;

#Query no mongo para ver logs de uma corrida
# db.getCollection('logs').find({idReference: "6e31ec22-68d7-8cd4-083c-fae704e2cac5"}).sort({date:-1}).limit(1000)

#Transferencias (saque)
SELECT
  u.name,
  withdraw.*
FROM withdraw
  INNER JOIN user u on withdraw.userId = u.idUser;

#adicionar saldo

SELECT * FROM user WHERE name like '%rodrigo%';

# quantidade de corridas do dia
SELECT
  *
FROM trip_summary_view t
  WHERE
    t.status = 'finished' AND
    DATE_FORMAT(t.date, '%Y-%m-%d') = '2018-11-26';

# total de corridas realizadas
SELECT
  COUNT(*)
FROM trip t
  WHERE t.status = 'finished';

# total de corridas canceladas
SELECT
  COUNT(*)
FROM trip t
  WHERE t.status = 'canceled' AND t.driverId IS NOT NULL;

# total de corridas não atendidas
SELECT
  COUNT(*)
FROM trip t
  WHERE t.status = 'canceled' AND t.driverId IS NULL;

# total de comissao dos parceiros
SELECT
  SUM(b.blockedBalance + b.balance)
FROM balance b
  INNER JOIN customer c on b.idBalance = c.balanceId
  INNER JOIN user u on c.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
WHERE la.userTypeId = 6;

# total de comissao dos motoristas
SELECT
  SUM(
    b.blockedBalance +
    b.balance +
    COALESCE(
      (
        SELECT
          SUM(w.value)
        FROM withdraw w
          WHERE w.balanceId = b.idBalance
      ), 0
    )
  ) AS total
FROM balance b
  INNER JOIN driver d on b.idBalance = d.balanceId
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
WHERE la.userTypeId = 3;

SELECT
  AVG(t.price)
FROM trip t;

# media de kilometragem por corrida
SELECT
  AVG((6371 * acos(
     cos( radians(ts.originLatitude) )
     * cos( radians(ts.destinationLatitude) )
     * cos( radians(ts.destinationLongitude) - radians(ts.originLongitude))
     + sin( radians(ts.originLatitude) )
     * sin( radians(ts.destinationLatitude) )
     )
  )) AS km_avg
FROM trip_summary_view ts;

# calcular distancia de uma viagem em km a partir do ponto de origem ao destino
SELECT
  (6371 * acos(
     cos( radians(ts.originLatitude) )
     * cos( radians(ts.destinationLatitude) )
     * cos( radians(ts.destinationLongitude) - radians(ts.originLongitude))
     + sin( radians(ts.originLatitude) )
     * sin( radians(ts.destinationLatitude) )
     )
  ) AS distance,
  ts.originAddress,
  ts.destinationAddress
FROM trip_summary_view ts;

SELECT
  *
FROM trip_summary_view;

# MOTORISTAS DISPONÍVEIS
SELECT
  u.idUser,
  u.created_at,
  u.name,
  u.email,
  d.status
#   COUNT(t.idTrip) AS quantidade_corrida
FROM driver d
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
#   LEFT JOIN trip t ON t.driverId = d.idDriver
WHERE la.userTypeId = 8;
#   GROUP BY t.driverId ORDER BY quantidade_corridas DESC;

SELECT
#   d.idDriver,
#   u.name,
#   u.email
  COUNT(*)
FROM driver d
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN trip t on t.driverId = d.idDriver
WHERE u.statusId = 1
  GROUP BY t.driverId;

SELECT
  bf.date,
  bf.value,
  bFT.name,
  fT.flow,
  bf.balanceFlowTypeId
FROM balanceFlow bf
  INNER JOIN balanceFlowType bFT on bf.balanceFlowTypeId = bFT.idBalanceFlowType
  INNER JOIN flowType fT on bFT.flowId = fT.id
  WHERE bf.balanceId = 418
ORDER BY bf.date DESC;

SELECT
  *
FROM user
  INNER JOIN driver d on user.idUser = d.userId
# WHERE d.idDriver = 102;
WHERE user.idUser = 1559;

SELECT
  u.name,
  u.email,
  Type.name
FROM user u
  INNER JOIN levelAccess Access on u.idUser = Access.userId
  INNER JOIN userType Type on Access.userTypeId = Type.idUserType
  WHERE u.email = 'paullosergio40@hotmail.com';

SELECT
  *
FROM balance
  WHERE idBalance = 315;

SELECT
  *
FROM trip t
  WHERE t.driverId = 70
ORDER BY t.date DESC;

SELECT
  bF.date,
  bF.value,
  bF.tripReference,
  bFT.name,
  bFT.flow
FROM balanceFlow bF
  INNER JOIN balance b on bF.balanceId = b.idBalance
  INNER JOIN customer c on b.idBalance = c.balanceId
  INNER JOIN balanceFlowType bFT on bF.balanceFlowTypeId = bFT.idBalanceFlowType
  WHERE c.idCustomer = 2248
ORDER BY bF.date DESC;
# UPDATE customer SET customerRegisterStatusId = 1 WHERE customerRegisterStatusId = 2

# LISTA DE CLIENTES FINAIS
SELECT
  *
FROM user
  INNER JOIN levelAccess la on user.idUser = la.userId
  INNER JOIN customer c on user.idUser = c.userId
  INNER JOIN balance b on c.balanceId = b.idBalance
WHERE la.userTypeId = 5 AND
      (user.email LIKE '%Sara%');

SELECT
  *
FROM trip_summary_view
  WHERE userId = 1882;

SELECT
  u.idUser,
  u.name,
  u.phone,
#   p.alias
  b.tripBalance,
  b.withheldBalance,
  b.idBalance
FROM customer c
  INNER JOIN user u on c.userId = u.idUser
  INNER JOIN balance b on c.balanceId = b.idBalance
#   LEFT JOIN places p on c.placeId = p.idPlace
  WHERE c.userId = 574;

SELECT
  *
FROM balanceFlow bf
  INNER JOIN balanceFlowType bFT on bf.balanceFlowTypeId = bFT.idBalanceFlowType
  WHERE bf.balanceId = 441
ORDER BY bf.date DESC;

# LISTA DE PARCEIROS
SELECT
  *
FROM user u
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN customer c on u.idUser = c.userId
  INNER JOIN balance b on c.balanceId = b.idBalance
WHERE la.userTypeId = 6 AND u.statusId = 1;

SELECT
  *
FROM user u
  WHERE u.idUser = 502;

SELECT
  CONCAT(
    'AG: ', ba.agency, ' ', ba.agencyDigit, ', ',
    'CC: ', ba.numberAccount, '-', ba.numberAccountDigit, ', '
    'OP: ', ba.op, ', ',
    'Titular: ', ba.holderName, ' - ', ba.document, ', '
    'Tipo da Conta: ', ba.typeAccount, ', '
    'Banco: ', b.bankNumber, ' - ', b.bankName
  ) AS bankAccount
FROM user u
  INNER JOIN bankAccount ba on u.bankAccountId = ba.idBankAccount
  INNER JOIN bank b on ba.bankId = b.idBank
WHERE u.email LIKE 'nonato_souzat@hotmail.com';

SELECT
  *
FROM driverStation ds
  INNER JOIN station s on ds.stationId = s.idStation
WHERE ds.driverId = 104;

# Consultar cliente parceiro
SELECT
  p.alias,
  p.address,
  p.latitude,
  p.longitude,
  city.nome,
  u.name,
  u.email,
  u.nickname,
  u.phone
FROM user u
  INNER JOIN customer c on u.idUser = c.userId
  INNER JOIN places p on c.placeId = p.idPlace
  LEFT JOIN city on p.cityId = city.id
  WHERE u.idUser = 502;

SELECT
  d.idDriver,
  u.idUser,
  u.name,
  u.email,
#   u.password,
  d.appVersion,
  d.last_lat,
  d.last_lon,
  d.status,
  d.balanceId
FROM user u
  INNER JOIN driver d on u.idUser = d.userId
ORDER BY d.appVersion DESC;

# UPDATE user SET email = 'paullosergio40@hotmail.com' WHERE idUser = 544;

# BUSCANDO CPF SEM MÁSCARA
SELECT
  REPLACE(REPLACE(u.document, '.', ''), '-', '') as document
FROM user u;

SELECT
  u.name,
  w.created_at,
  w.paymentDate,
  w.value,
  w.balanceId
FROM withdraw w
  INNER JOIN balance b on w.balanceId = b.idBalance
  LEFT JOIN driver d on b.idBalance = d.balanceId
  LEFT JOIN user u on d.userId = u.idUser
WHERE d.idDriver = 113 ORDER BY w.created_at DESC;

SELECT
  *
FROM withdraw w
  WHERE w.balanceId = 418;

SELECT
    u.document
FROM user u
  INNER JOIN levelAccess la ON la.userId = u.idUser
WHERE la.userTypeId = :userTypeId AND REPLACE(REPLACE(u.document, '.', ''), '-', '') = :document
  LIMIT 1;

# CLIENTES CADASTRADOS POR DIA
SELECT
    u.created_at,
    u.idUser,
    u.name,
    u.email,
    u.password,
    u.document,
    u.phone,
    COUNT(DISTINCT(u.idUser)) AS quantity
FROM user u
  INNER JOIN levelAccess la ON la.userId = u.idUser
  INNER JOIN trip t on u.idUser = t.userId
WHERE la.userTypeId = 5 AND u.statusId = 1
  GROUP BY u.idUser;

# UPDATE user SET statusId = 2 WHERE idUser = 558;

SELECT
  *
FROM trip_summary_view ts
  WHERE ts.driverId = 89;

SELECT
  *
FROM balanceFlow;

SELECT
  *
FROM user u
    WHERE u.idUser = 513;

SELECT
  *
FROM trip_summary_view ts
  WHERE ts.userId = 513;

SELECT
  COUNT(u.idUser) AS quantity
FROM user u
  INNER JOIN levelAccess la on u.idUser = la.userId
WHERE la.userTypeId = 5 AND u.created_at > '2018-12-01 19:00:00';

# INDICADORES DE CORRIDAS
SELECT
  COUNT(t.idTrip) AS tripQuantity,
  FORMAT(SUM(t.price), 2) AS totalPrice,
  FORMAT(AVG(t.price), 2) AS mediaPrice
#   uc.name AS customerName,
#   t.price,
#   t.status,
#   t.date,
#   t.endDate
FROM trip t
#   INNER JOIN driver d ON d.idDriver = t.driverId
#   INNER JOIN user ud on d.userId = ud.idUser
  INNER JOIN user uc on t.userId = uc.idUser
WHERE
#   t.status = 'canceled' AND t.canceledBy = 'customer' AND
  DATE_FORMAT(t.date, '%Y-%m-%d') >= '2019-01-03' AND
  t.tripTypeId = 1 AND
#   t.status = 'finished' AND
#   t.canceledBy = 'driver' AND
#   (t.status = 'back_off' OR t.status = 'canceled' OR t.status = 'not_answered') AND
#   t.tripPaymentFormId = 2 AND
#   t.driverId IS NOT NULL AND
#   t.driverId IS NULL AND
  t.userId NOT IN
  (484, 485, 505, 510, 541, 558, 564, 578, 588, 594, 595, 516, 545, 546, 547, 562, 568, 607, 623, 633, 832, 955, 957, 961, 994, 997)
#   GROUP BY t.driverId
ORDER BY t.date DESC;

#   INNER JOIN levelAccess la on u.idUser = la.userId
# WHERE la.userTypeId = 4
# 8.9466 / 380

SELECT
#   d.idDriver,
  u.name,
  bf.date,
  fT.flow,
  bFT.name,
  bf.value,
  t.price,
  bf.tripReference
#     SUM(bf.value) AS totalCredito
#   u.email,
#   SUM(bf.value) AS valor,
#   SUM(t.price) AS precoCorrida
FROM balanceFlow bf
  INNER JOIN balance b on bf.balanceId = b.idBalance
  INNER JOIN driver d on b.idBalance = d.balanceId
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN balanceFlowType bFT on bf.balanceFlowTypeId = bFT.idBalanceFlowType
  INNER JOIN flowType fT on bFT.flowId = fT.id
  LEFT JOIN trip t on bf.tripReference = t.tripReference
WHERE
#   bf.tripReference IS NOT NULL AND
  #Entrada e saida imediata de carteira por pagamento no carro
  bf.balanceFlowTypeId NOT IN (16, 19) AND
  #Entradas e saídas excluidas
  bFT.flowId NOT IN (5,6)
  #Valor de entrada por pagamentos em voucher
#   bFT.flowId IN (1,3)
  #Valor de entrada por pagamentos em dinheiro
#   bFT.flowId IN (2,4)
  AND u.idUser = 574
# GROUP BY d.idDriver
ORDER BY bf.date DESC;

SELECT
  u.idUser,
  u.name,
  u.email,
#   bf.value,
#   bFT.name,
#   bFT.idBalanceFlowType,
#   bf.date,
  SUM(bf.value) AS valorTotal
#   COUNT(bf.idBalanceFlow) AS quantity
FROM balanceFlow bf
  INNER JOIN balance b on bf.balanceId = b.idBalance
  INNER JOIN driver d on b.idBalance = d.balanceId
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN balanceFlowType bFT on bf.balanceFlowTypeId = bFT.idBalanceFlowType
WHERE
  bf.balanceFlowTypeId = 6
GROUP BY d.idDriver ORDER BY valorTotal DESC;

SELECT
  bf.idBalanceFlow,
  t.tripReference,
  t.price,
  bf.value,
  bFT.flow,
  t.driverId,
  CASE
    WHEN t.originId IS NOT NULL THEN
      o.address
    ELSE
      est.fantasyName
  END AS originAddress,
  CASE
    WHEN t.stationId IS NOT NULL THEN
      s.name
    ELSE
      dest.address
  END AS destinationAddress,
  u.name AS driverName,
  bf.date
FROM trip t
  INNER JOIN balanceFlow bf ON t.tripReference = bf.tripReference
  INNER JOIN balanceFlowType bFT ON bf.balanceFlowTypeId = bFT.idBalanceFlowType
  LEFT JOIN establishment est ON t.establishmentId = est.idEstablishment
  LEFT JOIN origin o ON t.originId = o.idOrigin
  LEFT JOIN station s ON t.stationId = s.idStation
  LEFT JOIN destination dest ON t.destinationId = dest.idDestination
  LEFT JOIN driver d ON t.driverId = d.idDriver
  LEFT JOIN user u ON d.userId = u.idUser
WHERE (bFT.flowId = 3 OR bFT.flowId = 4) AND bf.balanceId = 315
GROUP BY bf.tripReference ORDER BY bf.date DESC;

SELECT
  *
FROM city c
  WHERE nome LIKE '%Barbalha%';

SELECT
  *
FROM user
  INNER JOIN customer c on user.idUser = c.userId
WHERE user.idUser = 601;

SELECT
  *
FROM trip_summary_view t
  INNER JOIN user u on t.userId = u.idUser
WHERE u.idUser = 582
  ORDER BY date DESC;

SELECT
  COUNT(t.idTrip) AS quantity
FROM trip t
  WHERE
    t.status = 'finished' AND
    WEEK(t.date) = (WEEK(CURDATE()) - 1);

# RANKING DIÁRIO DE CORRIDAS
SELECT
  u.name,
  u.email,
  COUNT(t.idTrip) AS tripQuantity,
  FORMAT(SUM(t.price), 2) AS totalPrice
FROM trip t
  INNER JOIN driver d ON d.idDriver = t.driverId
  INNER JOIN user u on d.userId = u.idUser
  WHERE DATE_FORMAT(t.date, '%Y-%m-%d') = '2018-12-15'
GROUP BY t.driverId ORDER BY tripQuantity DESC;

# RANKING SEMANAL DE CORRIDAS
SELECT
  u.name,
  u.email,
  COUNT(t.idTrip) AS tripQuantity,
  FORMAT(SUM(t.price), 2) AS totalPrice
FROM trip t
  INNER JOIN driver d ON d.idDriver = t.driverId
  INNER JOIN user u on d.userId = u.idUser
  WHERE
    WEEK(t.date) = WEEK('2019-01-25') AND
    YEAR(t.date) = YEAR('2019-01-25') AND
    t.status = 'finished'
GROUP BY t.driverId ORDER BY tripQuantity DESC;

# RANKING MENSAL DE CORRIDAS
SELECT
  u.name,
  u.rating,
#   ut.name AS driverType,
  COUNT(t.idTrip) AS tripQuantity,
  CONCAT('R$ ', FORMAT(SUM(t.price), 2, 'de_DE')) AS totalPrice
FROM trip t
  INNER JOIN driver d ON d.idDriver = t.driverId
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN userType ut on la.userTypeId = ut.idUserType
  WHERE
#     DATE_FORMAT(t.date, '%Y-%m') = '2019-01' AND t.status = 'finished' AND
    ut.idUserType <> 8 AND
    t.status = 'finished'
  GROUP BY t.driverId
#   HAVING
#       tripQuantity >= 20
# GROUP BY t.driverId
ORDER BY tripQuantity DESC;
# GROUP BY DATE_FORMAT(t.date, '%Y-%m-%d') ASC ORDER BY tripQuantity DESC;

# RANKING POR PERÍODO
SELECT
  u.name,
#   u.email,
#   DATE_FORMAT(t.date, '%Y-%m-%d'),
  COUNT(t.idTrip) AS tripQuantity,
  FORMAT(SUM(t.price), 2, 'de_DE') AS totalPrice
FROM trip t
  INNER JOIN driver d ON d.idDriver = t.driverId
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN userType ut on la.userTypeId = ut.idUserType
  WHERE DATE_FORMAT(t.date, '%Y-%m-%d') = '2018-11-29' AND t.status = 'finished'
GROUP BY t.driverId ORDER BY tripQuantity DESC;

SELECT
  u.name,
  u.email,
  COUNT(t.idTrip) AS tripQuantity,
  SUM(t.price) AS totalPrice
FROM trip t
  INNER JOIN driver d ON d.idDriver = t.driverId
  INNER JOIN user u on d.userId = u.idUser
  WHERE DATE_FORMAT(t.date, '%Y-%m-%d') = '2018-12-13'
GROUP BY t.driverId ORDER BY tripQuantity DESC;

SELECT
  *
FROM trip t
  INNER JOIN driver d ON t.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
  WHERE
      t.status = 'finished'
GROUP BY t.driverId;

SELECT
    dbf.date,
    dbf.flow,
    CASE
        WHEN dbf.flow = 'entrada' THEN
          CONCAT('-',dbf.value)
        ELSE
          dbf.value
    END AS value,
    ft.name,
    dbf.summary
FROM driver_balance_flow_view dbf
  INNER JOIN driver d ON dbf.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN balanceFlowType ft on dbf.balanceFlowTypeId = ft.idBalanceFlowType
WHERE d.idDriver = 113
  ORDER BY
    dbf.date DESC,
    dbf.idBalanceFlow ASC;

# CLIENTE QUE FIZERAM PELO MENOS 1 VIAGEM
SELECT
  u.name,
  u.email,
  COUNT(DISTINCT(t.idTrip)) AS tripQuantity,
  SUM(t.price)
FROM user u
  INNER JOIN trip t on u.idUser = t.userId
  INNER JOIN levelAccess la on u.idUser = la.userId
  WHERE la.userTypeId = 5 AND t.status = 'finished'
GROUP BY t.userId;

# CHAMADAS NÃO ATENDIDAS
SELECT
  DATE_FORMAT(t.date, '%Y-%m-%d') AS date,
  COUNT(t.idTrip)
FROM user u
  INNER JOIN trip t on u.idUser = t.userId
  INNER JOIN levelAccess la on u.idUser = la.userId
  WHERE DATE_FORMAT(t.date, '%Y-%m-%d') >= '2018-11-01' AND
        ((t.status = 'canceled' OR t.status = 'back_off' OR t.status = 'not_answered') AND t.driverId IS NULL)
GROUP BY DATE_FORMAT(t.date, '%Y-%m-%d');

SELECT
  *
FROM balance b
  INNER JOIN driver d on b.idBalance = d.balanceId
WHERE d.idDriver = 113;

SELECT
    u.idUser,
    u.name,
    u.email,
    b.tripBalance,
    u.deviceToken
FROM user u
  INNER JOIN customer c on c.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN balance b on c.balanceId = b.idBalance
WHERE b.tripBalance > 0;

# UPDATE balance b SET tripBalance = 0
# WHERE
#   b.idBalance IN (392,396,398,399,400,401,403,409,410,415,416,423,424,426,428,431,433,435,436,437,441,442,443,446,447,448,449,450,451,455,463,464,465,466,467,470,472,475,478,479,480,481,482,487,488,491,493,494,495,496,497,500,501,503,504,505,506,507,510,511,512,513,515,516,518,519,520,521,523,524,525,527,528,529,530,531,532,533,534,535,536,537,538,539,540,541,542,543,544,546,547,548,549,550,552,553,554,555,557,558,559,566,571,574,590,597,604,605,615,625,626,627,628,629,631,632,634,635,636,637,638,639,640,641,642,644,646,647,648,650,651,654,655,658,665,667,668,672,673,674,675,676,677,679,680,681,682,683,684,685,686,687,688,689,693,695,696,697,700,701,704,706,707,708,709,710,712,713,716,717,719,720,723,724,728,729,730,735,736,739,743,744,748,750,753,755,756,757,758,761,763,766,767,770,774,775,781,782,820,828,842,853,877,948,950,976,984,994,1007,1049,1116,1206);

# CORRIDAS DE UM MOTORISTA
SELECT
  *
FROM trip_summary_view WHERE driverId = 88;

select count(`driver`.`idDriver`) as available_drivers
  from `driver`
    INNER JOIN user u ON driver.userId = u.idUser
  where (`driver`.`status` = 'disponivel') AND u.statusId = 1;

SELECT
  t.date,
  t.driverName,
  t.customerName,
  t.price,
  t.status,
  t.situation,
  t.paymentForm,
  t.originAddress,
  t.destinationAddress
#   t.tripReference
FROM trip_summary_view t
  WHERE
#     t.status = 'finished' AND (
    (
#       t.originAddress LIKE '%Barbalha%' OR
#       t.originAddress LIKE '%barbalha%' OR
      t.originAddress LIKE '%Crato%' OR
      t.originAddress LIKE '%crato%'
    ) AND
    (DATE_FORMAT(t.date, '%Y-%m-%d') >= '2019-01-12' AND
     DATE_FORMAT(t.date, '%Y-%m-%d') <= '2019-01-25');

SELECT
  t.date,
  t.driverId,
  t.driverName,
  t.customerName,
  t.price,
  t.situation,
  t.paymentForm,
  t.originAddress,
  t.destinationAddress,
  t.tripReference
FROM trip_summary_view t
  WHERE
    t.status = 'finished' AND (
      t.destinationAddress LIKE '%Barbalha%' OR
      t.destinationAddress LIKE '%barbalha%' OR
      t.destinationAddress LIKE '%Crato%' OR
      t.destinationAddress LIKE '%crato%'
    );

SELECT
       d.idDriver,
       u.name,
       COUNT(*) as amountTrip,
       format(SUM(t.price),2,'de_DE'),
       DATE_FORMAT(t.date,'%d/%m/%Y')
  FROM trip t
         INNER JOIN driver d ON t.driverId = d.idDriver
         INNER JOIN user u ON u.idUser = d.userId
WHERE t.status = 'finished'
GROUP BY DATE_FORMAT(t.date,'%Y-%m-%d'), t.driverId
ORDER BY t.date ASC ,amountTrip DESC;

SELECT
  *
FROM user
  INNER JOIN levelAccess la on user.idUser = la.userId
WHERE la.userTypeId = 7;

SELECT * FROM zone  WHERE cityId = :cityId AND zone.order = :orderFirst AND statusId = :statusId;

SELECT
  *
FROM tripDrivers td
  WHERE TIME_TO_SEC(TIMEDIFF('2019-01-04 16:34:30', td.date)) > td.timeToIncrease;

SELECT
  s.name,
  s.address,
  s.latitude,
  s.longitude,
  s.stationTypeId
FROM driverStation ds
  INNER JOIN station s on ds.stationId = s.idStation
  INNER JOIN driver d on ds.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
# WHERE d.idDriver = 79;
WHERE u.idUser = 2122;

SELECT * FROM levelAccess la
  WHERE la.userId = 828;

SELECT * FROM user u
  WHERE u.idUser = 574;

SELECT
#   u.name,
#   u.email,
#   th.date,
#   th.tripReference,
#   CASE
#       WHEN th.status = 'denied' THEN 'recusou'
#       WHEN th.status = 'accepted' THEN 'aceitou'
#       WHEN th.status = 'calling' THEN 'chamou'
#   END AS status,
#   th.countDenied
  u.name,
  th.status,
  th.date
FROM tripHistory th
  INNER JOIN driver d on th.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
WHERE th.tripReference = '58540ef8-ce8a-e4bb-8db3-ea0b788d193f';

SELECT
  u.name,
  u.created_at,
  s.address,
  s.latitude,
  s.longitude
FROM driver d
  INNER JOIN station s on d.stationId = s.idStation
  INNER JOIN user u on d.userId = u.idUser
WHERE s.latitude IS NULL OR s.longitude IS NULL;

SELECT
  *
FROM user u
  INNER JOIN levelAccess la on u.idUser = la.userId
WHERE la.userTypeId = 7;

# 113, 574

# ESTATÍSTICAS PELA FORMA DE PAGAMENTO ÚLTIMAS 100 VIAGENS FINALIZADAS
SELECT
  tpf.name AS paymentForm,
  COUNT(t.idTrip) AS quantity,
  FORMAT(SUM(t.price), 2, 'de_DE') AS value
FROM (
  SELECT t.idTrip, t.tripPaymentFormId, t.price FROM trip t
    INNER JOIN driver d ON t.driverId = d.idDriver
  WHERE t.status = 'finished' ORDER BY t.date DESC LIMIT :limit
 ) AS t
  INNER JOIN tripPaymentForm tpf on t.tripPaymentFormId = tpf.idTripPaymentForm
  GROUP BY paymentForm;

SELECT
  u.idUser,
  d.idDriver,
  u.name,
  u.email,
  u.bankAccountId,
  d.driverRegisterStatusId,
  b.balance,
  b.idBalance,
  b.pendingBalanceWithdraw,
  bk.bankName,
  bk.bankNumber
FROM user u
  INNER JOIN driver d on u.idUser = d.userId
  INNER JOIN station s on d.stationId = s.idStation
  INNER JOIN balance b on d.balanceId = b.idBalance
  INNER JOIN bankAccount ba on u.bankAccountId = ba.idBankAccount
  INNER JOIN bank bk on ba.bankId = bk.idBank
  WHERE u.idUser = 489;

SELECT
  *
FROM balance b
  WHERE b.idBalance = 339;

SELECT
  DAYOFWEEK(SUBDATE(NOW(), 4));

SELECT
  *
FROM priceDynamic pd
  INNER JOIN schedulePriceDynamic sPD on pd.idPriceDynamic = sPD.priceDynamicId
WHERE
    pd.statusId = 1 AND
    (
        (
            (TIME_FORMAT('2019-01-04 15:40:00', '%H:%i:%s') BETWEEN sPD.timeStart AND sPD.timeEnd) AND
            sPD.statusId = 1
        ) OR
        pd.activatedManual = 1
    ) AND
    DAYOFWEEK('2019-01-04 15:40:00') = pd.dayOfWeek AND
    pd.cityId = 756;

# BUSCANDO USUARIO PELO EMAIL
SELECT
  *
FROM user u
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN driver d on u.idUser = d.userId
#   WHERE u.email LIKE '%talo.bruno.dantas@gmail.com%';
#   WHERE u.name LIKE '%da%'
  WHERE u.email LIKE '%davidsousa8675@outlook.com%'
    AND la.userTypeId = 7;

SELECT
  u.name,
  u.email,
  d.appVersion
FROM user u
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN driver d on u.idUser = d.userId
#   WHERE u.email LIKE '%talo.bruno.dantas@gmail.com%';
#   WHERE u.name LIKE '%da%'
  WHERE (la.userTypeId = 7 OR la.userTypeId = 3)
#   u.email LIKE '%tstjunior2000@yahoo.com.br%';
    AND (d.appVersion = '1.5.0' OR d.appVersion = '1.6.0')
ORDER BY d.appVersion DESC;

SELECT
  *
FROM levelAccess la
  WHERE la.userId = 2432;

SELECT
  COUNT(t.driverId) AS quantity_canceled,
  u.name,
  u.phone,
  u.email
#   COUNT(t.idTrip) AS totalCanceled
FROM trip t
#   INNER JOIN user u on t.userId = u.idUser
  INNER JOIN driver d ON d.idDriver = t.driverId
  INNER JOIN user u on d.userId = u.idUser
  WHERE
    DATE_FORMAT(t.date, '%Y-%m') = '2019-01' AND
    t.driverId IS NOT NULL AND
#     t.status = 'canceled'
    t.status = 'canceled' AND
    t.canceledBy = 'driver'
  GROUP BY t.driverId
ORDER BY quantity_canceled DESC;

SELECT
  bu.idBlacklistUser,
  bu.created_at,
  bu.expiration_time,
  bu.timeSuspended,
  bu.userId,
  bu.statusId,
  la.userTypeId
FROM blacklistUser bu
  INNER JOIN user u on bu.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
WHERE bu.expiration_time < '2019-01-16 14:40:00' AND bu.statusId = 1;

# CLIENTES QUE FIZERAM CHAMADAS NÃO ATENDIDAS EM DEZEMBRO 2018
SELECT
  t.userId,
  t.customerName,
  t.customerPhone,
  COUNT(t.idTrip) AS countTrip
FROM trip_summary_view t
  WHERE
    (t.status = 'back_off' OR t.status = 'not_answered' OR t.status = 'canceled') AND
    t.userId NOT IN (
        SELECT
          t.userId
        FROM trip_summary_view t
          WHERE
              t.status = 'finished' AND DATE_FORMAT(t.date, '%Y-%m') = '2018-12'
        GROUP BY t.userId
    ) AND
    DATE_FORMAT(t.date, '%Y-%m') = '2018-12'
GROUP BY t.userId ORDER BY countTrip DESC;

SELECT
  *
FROM user u
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN customer c on u.idUser = c.userId
WHERE la.userTypeId = 5 AND c.userId NOT IN (
    SELECT
      t.userId
    FROM trip_summary_view t
      WHERE
        DATE_FORMAT(t.date, '%Y-%m') = '2018-12'
    GROUP BY t.userId
);

SELECT
  FORMAT(AVG(tr.rating), 2) AS avg,
  COUNT(*)
FROM tripRating tr
  WHERE tr.ratedUser = 574 LIMIT 30;

SELECT
  c.value AS ratingLimit
FROM config c
  WHERE c.key = 'limit_trip_for_rating_average';

SELECT
    *
FROM blacklistUserConfig bu
  WHERE bu.penaltiesQuantity >= 7 AND bu.statusId = 1
ORDER BY bu.penaltiesQuantity ASC LIMIT 1;

SELECT
  d.idDriver,
  user.name,
  d.status,
  d.appIsOpen
FROM user
  inner join driver d on user.idUser = d.userId
  inner join levelAccess la on user.idUser = la.userId
WHERE d.appIsOpen IS NOT NULL AND d.status = 'disponivel'
  ORDER BY d.appIsOpen DESC;

SELECT
  TIMEDIFF(dC.updated_at, '2019-01-21 10:48:00') AS secondsRemain,
  tD.*
FROM driverCalled dC
  INNER JOIN tripDrivers tD ON dC.tripReference = tD.tripReference
WHERE dC.driverId = 12 AND tD.callingDriver = 12;

# Lista de motoristas
SELECT
#   d.idDriver,
#   user.idUser,
#   user.created_at,
  u.idUser,
  d.idDriver,
  u.rating,
  u.name,
#   u.email,
  t.name AS type,
  d.status,
  d.appVersion,
  d.appIsOpen
#   user.email,
#   user.phone,
#   user.statusId,
#   d.balanceId,
#   b.blockedBalance,
#   b.balance,
#   b.pendingBalanceWithdraw,
#   d.appVersion
FROM user u
  INNER JOIN driver d on u.idUser = d.userId
  INNER JOIN balance b on d.balanceId = b.idBalance
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN userType t on la.userTypeId = t.idUserType
  LEFT JOIN station s on d.stationId = s.idStation
  WHERE
    u.statusId = 1
#     d.driverRegisterStatusId = 1 AND
#     u.name LIKE '%Bet%'
ORDER BY d.appVersion DESC, u.rating ASC;
# WHERE user.name LIKE '%She%';

# UPDATE user SET rating = 5 WHERE idUser = 2684;

SELECT * FROM levelAccess la WHERE la.userId = 297;

# BUSCANDO RETURN ATIVO DO MOTORISTA
SELECT
  d.idDriver,
  u.name,
  d.status,
  d.appIsOpen,
  d.appVersion,
  b.balance,
  b.blockedBalance
FROM driver d
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN balance b on d.balanceId = b.idBalance
  LEFT JOIN station s ON d.stationId = s.idStation
# WHERE d.idDriver = 229;
WHERE la.userTypeId = 8;

SELECT
  *
FROM driverStation dS
  WHERE dS.driverId = 229;

# BUSCANDO CLIENTES FAVORITOS DE UM MOTORISTA
SELECT
  u.name,
  u.phone
FROM favoriteDriver fd
  INNER JOIN customer c on fd.customerId = c.idCustomer
  INNER JOIN user u on c.userId = u.idUser
  WHERE fd.driverId = 186;

SELECT
  ts.tripReference,
  th.date,
  th.status,
  ts.customerName,
  ts.price,
  ts.originAddress,
  ts.destinationAddress
FROM trip_summary_view ts
  INNER JOIN tripHistory th ON th.tripReference = ts.tripReference
  WHERE FIND_IN_SET(186, ts.favoriteDrivers) > 0
GROUP BY ts.tripReference;

SELECT
  *
FROM tripHistory th
  WHERE th.driverId = 186;

SELECT
  u.name,
  dot.time_in,
  dot.time_out,
  DATE_FORMAT(dot.time_in, '%Y-%m-%d') AS date,
  TIMEDIFF(dot.time_out, dot.time_in),
  ut.name AS type
FROM driverOnlineTime dot
  INNER JOIN driver d on dot.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN userType ut on la.userTypeId = ut.idUserType
WHERE dot.driverId = 228;
#   GROUP BY date

# LISTANDO MOTORISTAS CHAMADOS NA VIAGEM
SELECT
  d.idDriver,
  dC.tripReference,
  dC.proximity,
  dC.status,
  u.name,
  u.rating,
  t.name AS type,
  dC.created_at,
  dC.updated_at
FROM driverCalled dC
  INNER JOIN driver d on dC.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN userType t on la.userTypeId = t.idUserType
WHERE dC.tripReference = '58540ef8-ce8a-e4bb-8db3-ea0b788d193f';
# WHERE dC.driverId = 228 AND dC.updated_at IS NOT NULL;

# MOTORISTAS QUE CHAMADOS
SELECT
  th.date,
  d.idDriver,
  u.name,
  th.status,
  th.countDenied
FROM tripHistory th
  INNER JOIN driver d on th.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN userType t on la.userTypeId = t.idUserType
WHERE
#     th.tripReference = 'bc46d86f-7ab8-96ca-3ae1-1f806a198e95';
    th.driverId = 228;

SELECT
  *
FROM trip_summary_view ts
  WHERE ts.driverId = 311;

SELECT
  *
FROM driverCalled dC
  INNER JOIN driver d on dC.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
WHERE d.idDriver = 223 AND dC.status IS NOT NULL;

SELECT
  *
FROM userPenalty
  INNER JOIN user u on userPenalty.userId = u.idUser
  INNER JOIN driver d on u.idUser = d.userId
WHERE d.idDriver = 311;

SELECT
  d.idDriver,
  u.idUser,
  u.name,
  ut.name AS type,
  u.rating,
  d.status,
  d.stationId,
  d.appIsOpen,
  d.appVersion,
  s.address
FROM driver d
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN userType ut on la.userTypeId = ut.idUserType
  LEFT JOIN station s on d.stationId = s.idStation
# WHERE d.appIsOpen IS NOT NULL
# WHERE u.email LIKE '%Jnilton12@gmail.com%';
WHERE u.name LIKE '%leonardo%';
# WHERE d.idDriver = 226
#   ORDER BY d.appVersion DESC;

SELECT
  *
FROM user u
  WHERE u.idUser = 552;

SELECT
  *
FROM blacklistUser bu
  WHERE bu.userId = 2674;

# AVALIAÇÃO ATUAL DOS MOTORISTAS
SELECT
  u.name,
  u.rating,
  ut.name AS type
FROM user u
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN userType ut on la.userTypeId = ut.idUserType
WHERE la.userTypeId IN (3,7,8)
  ORDER BY u.rating ASC;

# CALCULANDO AVALIAÇÃO DE UM USUÁRIO(MOTORISTA)
SELECT
  (
      (
          (
              30 - IF((
                    SELECT
                      COUNT(rating)
                    FROM tripRating
                      WHERE tripRating.ratedUser = tr.ratedUser
                    LIMIT 30
                  ) = 0, 30, (
                    SELECT
                      COUNT(rating)
                    FROM tripRating
                      WHERE tripRating.ratedUser = tr.ratedUser
                    LIMIT 30
                  ))
          ) * 5
      ) + IFNULL((
        SELECT
          SUM(rating)
        FROM tripRating
          WHERE tripRating.ratedUser = tr.ratedUser
        LIMIT 30
      ), 150)
  ) / 30 AS avg,
  u.name,
  ut.name AS type
FROM user u
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN userType ut on la.userTypeId = ut.idUserType
  LEFT JOIN tripRating tr on u.idUser = tr.ratedUser
  WHERE la.userTypeId IN (3,7,8)
GROUP BY u.idUser ORDER BY avg ASC;

# UPDATE user SET rating = 5 WHERE idUser = 463;

# LISTAR ÚLTIMAS AVALIAÇÕES
SELECT
  u.idUser,
  tr.created_at,
  tr.rating,
  tr.tripReference,
  u.name,
  la.userTypeId
FROM tripRating tr
  INNER JOIN user u on tr.ratedUser = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  WHERE tr.ratedUser = 2713
ORDER BY tr.created_at DESC;

SELECT
  TIMEDIFF(ts.endDate, ts.date) AS diff,
  COUNT(TIMEDIFF(ts.endDate, ts.date)) AS contador
FROM trip_summary_view ts
  WHERE
    (ts.status = 'canceled' OR ts.status = 'not_answered' OR ts.status = 'back_off') AND
  ts.driverId IS NULL
  GROUP BY diff
LIMIT 300;

SELECT
  FORMAT((6371 * acos(
         cos( radians(-3.7485488) )
         * cos( radians( d.last_lat ) )
         * cos( radians( d.last_lon ) - radians(-38.4934472) )
         + sin( radians(-3.7485488) )
         * sin( radians( d.last_lat ) )
        )
    ), 4) AS proximity,
  u.name,
  la.userTypeId,
  t.name AS type,
  tt.type AS tripType,
  ttd.tripTypeId
FROM driver d
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN userType t on la.userTypeId = t.idUserType
  INNER JOIN tripTypeDriver ttd on (t.idUserType = ttd.userTypeId AND ttd.tripTypeId <> 1)
  INNER JOIN tripType tt on ttd.tripTypeId = tt.idTripType
#   INNER JOIN zone z ON (z.cityId = 756 AND z.statusId = 1)
  WHERE
    u.statusId = 1 AND
    d.status = 'disponivel' AND d.driverRegisterStatusId = 1
  HAVING
       proximity < (
        SELECT z.radius FROM zone z
          WHERE (z.cityId = 756 AND z.statusId = 1)
          GROUP BY z.cityId
      );
# ORDER BY proximity ASC;

# BUSCANDO MOTORISTA PELA PLACA DO CARRO
SELECT
  d.idDriver,
  u.name,
  c.brand,
  c.model,
  c.plate
FROM car c
  INNER JOIN driver d on c.driverId = d.idDriver
  INNER JOIN user u on d.userId = u.idUser
WHERE c.plate LIKE '%0863%';

# ESTATÍSTICAS DE VIAGEM DO MOTORISTA
SELECT
  FORMAT(
    IFNULL((SELECT SUM(ts.price)
            FROM trip_summary_view ts
            WHERE ts.driverId = 12
              AND ts.status = 'finished'
              AND DATE_FORMAT(ts.date, '%Y-%m-%d') = '2019-01-28'), 0),
      2, 'de_DE')AS value_collected,
  (SELECT
    COUNT(th.idTripHistory)
  FROM tripHistory th
    WHERE
       th.driverId = 12 AND
       DATE_FORMAT(th.date, '%Y-%m-%d') = '2019-01-28') AS quantity_calls,
  (SELECT
    COUNT(ts.idTrip)
  FROM trip_summary_view ts
    WHERE
       ts.driverId = 12 AND
       DATE_FORMAT(ts.date, '%Y-%m-%d') = '2019-01-28') AS quantity_accepted_calls,
  (SELECT
    COUNT(dc.id)
  FROM driverCalled dc
    WHERE
       dc.driverId = 12 AND
       dc.status = 'refused' AND
       DATE_FORMAT(dc.updated_at, '%Y-%m-%d') = '2019-01-28') AS quantity_refused_calls,
  (SELECT
    COUNT(ts.idTrip)
  FROM trip_summary_view ts
    WHERE
       ts.driverId = 12 AND
       ts.canceledBy = 'driver' AND
       DATE_FORMAT(ts.date, '%Y-%m-%d') = '2019-01-28') AS quantity_canceled_calls;

# HISTORICO VIAGENS CLIENTE
SELECT
  d.latitude,
  d.longitude,
  d.address,
  d.cityId,
  d.neighborhood
FROM destination d
  INNER JOIN trip t on d.idDestination = t.destinationId
WHERE t.userId = 574 and t.status = 'finished'
  GROUP BY d.address
  ORDER BY t.date DESC LIMIT 10;

# QUANTIDADES DE CORRIDAS POR HORA
SELECT
  HOUR(t.date) AS hour,
  COUNT(t.idTrip) AS quantity,
  tf.quantity AS quantity_finished
FROM trip t
  INNER JOIN (
    SELECT
      HOUR(t.date) AS hour,
      COUNT(t.idTrip) AS quantity,
      t.date
    FROM trip t
      WHERE
         t.status = 'finished' AND DATE_FORMAT(t.date, '%w') = 0
      GROUP BY hour) tf ON tf.hour = HOUR(t.date)
  WHERE
    (DATE_FORMAT(t.date, '%w') = 0)
GROUP BY hour;

# AGRUPANDO CHAMADOS POR BAIRRO
SELECT
  HOUR(t.date) AS hour,
  COUNT(DISTINCT t1.idTrip) AS domingo,
  COUNT(DISTINCT t2.idTrip) AS segunda,
  COUNT(DISTINCT t3.idTrip) AS terca,
  COUNT(DISTINCT t4.idTrip) AS quarta,
  COUNT(DISTINCT t5.idTrip) AS quinta,
  COUNT(DISTINCT t6.idTrip) AS sexta,
  COUNT(DISTINCT t7.idTrip) AS sabado,
  COUNT(DISTINCT t.idTrip) AS quantity,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(o.address, ',', 2), '-', -1)) as bairro
FROM trip t
  INNER JOIN origin o on t.originId = o.idOrigin
  LEFT JOIN trip t1 on (t.originId = t1.originId AND DAYOFWEEK(t1.date) = 1 AND t1.status = 'finished')
  LEFT JOIN trip t2 on (t.originId = t2.originId AND DAYOFWEEK(t2.date) = 2 AND t2.status = 'finished')
  LEFT JOIN trip t3 on (t.originId = t3.originId AND DAYOFWEEK(t3.date) = 3 AND t3.status = 'finished')
  LEFT JOIN trip t4 on (t.originId = t4.originId AND DAYOFWEEK(t4.date) = 4 AND t4.status = 'finished')
  LEFT JOIN trip t5 on (t.originId = t5.originId AND DAYOFWEEK(t5.date) = 5 AND t5.status = 'finished')
  LEFT JOIN trip t6 on (t.originId = t6.originId AND DAYOFWEEK(t6.date) = 6 AND t6.status = 'finished')
  LEFT JOIN trip t7 on (t.originId = t7.originId AND DAYOFWEEK(t7.date) = 7 AND t7.status = 'finished')
  WHERE
    t.status = 'finished' AND
    DATE_FORMAT(t.date, '%Y-%m-%d') >= '2019-01-02' AND
    DATE_FORMAT(t.date, '%Y-%m-%d') <= '2019-02-02'
GROUP BY bairro
  ORDER BY hour ASC, quantity DESC;

# BUSCANDO CLIENTE
SELECT
  *
FROM user u
  INNER JOIN levelAccess la on u.idUser = la.userId
WHERE u.idUser = 2350;

# BUSCANDO USUÁRIOS ADMINS
SELECT
  u.*
FROM user u
  INNER JOIN levelAccess la on u.idUser = la.userId
WHERE la.userTypeId = 4;

SELECT
  *
FROM user u
  WHERE u.idUser = 303;

# BUSCANDO SAIDA DE COMISSÕES DO MOTORISTA
SELECT
  d.idDriver,
  u.name,
  b.balance,
  SUM((
    SELECT
      SUM(bf.value) AS total
    FROM balanceFlow bf
      INNER JOIN balance b on bf.balanceId = b.idBalance
      INNER JOIN balanceFlowType bft on bf.balanceFlowTypeId = bft.idBalanceFlowType
      INNER JOIN driver di on b.idBalance = di.balanceId
    WHERE
        di.idDriver = d.idDriver AND
        bf.balanceFlowTypeId = 8
  )) AS total,
  b.blockedBalanceToPay
FROM driver d
  INNER JOIN user u on d.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
  INNER JOIN balance b on d.balanceId = b.idBalance
WHERE
    la.userTypeId <> 8 AND la.userTypeId <> 3
  ORDER BY b.balance ASC;

# BUSCANDO MOTORISTA
# ON SERIA O WHERE DO INNER JOIN
SELECT
  u.idUser,
  u.name,
  u.email,
  u.phone,
  u.rating
FROM user u
g INNER JOIN driver d on u.idUser = d.userId
WHERE
  u.phone like '%8753%';

# Ver quem ta ativo na BlackList
SELECT
  bu.idBlacklistUser,
  bu.created_at,
  bu.expiration_time,
  bu.timeSuspended,
  bu.userId,
  bu.statusId,
  la.userTypeId
FROM blacklistUser bu
  INNER JOIN user u on bu.userId = u.idUser
  INNER JOIN levelAccess la on u.idUser = la.userId
# WHERE bu.statusId = 1;
WHERE bu.userId = 2469;

SELECT
  *
FROM userPenalty up
  WHERE up.userId = 2787;
;

# VER CORRIDAS DO MOTORISTA: AS QUE TOCARAM
# driverCalled = Motoristas próximos
SELECT
 *
FROM driverCalled dc
  WHERE dc.driverId = 311 AND dc.status is not null
  ORDER BY dc.created_at DESC;

# AS QUE TOCARAM COM O APLICATIVO LIGADO
SELECT
 *
FROM tripHistory th
  WHERE th.driverId = 311
  ORDER BY th.date DESC;

# MOSTRANDO APP DESATUALIZADO DE QUEM LOGOU RECENTEMENTE
SELECT
  u.name, u.rating, d.appVersion, d.appIsOpen, u.phone
FROM user u
  INNER JOIN driver d on u.idUser = d.userId
WHERE
  d.appVersion <> '1.9.0' AND d.appIsOpen is not null and u.name like "%Geraldo%";


SELECT 
  *
FROM user u
    INNER JOIN driver d on u.idUser = d.idDriver
WHERE 
  d.appVersion <> '1.11.0';

  SELECT
        u.name, d.appVersion,d.idDriver
    FROM user u

        INNER JOIN driver d on u.idUser = d.userId
    WHERE
        u.name like "%laermesson%";


SELECT
   sum(0.5)
FROM trip t where t.driverId=323 and t.status = 'finished'

SELECT
  *
FROM trip
WHERE userId = 106

SELECT user.name, idUser, idDriver
FROM user
  INNER JOIN driver ON user.idUser = driver.userId
WHERE name like '%anderson%'


SELECT count(idDriver) as Qtd, sum(driverCommission.value) as Taxa
FROM driver
  INNER JOIN user ON driver.userId = user.idUser
  INNER JOIN trip on driver.idDriver = trip.driverId
  INNER JOIN driverCommission ON trip.driverCommissionId = driverCommission.idDriverCommission
WHERE
  idDriver = 230
  and DATE_FORMAT(trip.date, '%Y-%m-%d') >= '2019-04-26' and DATE_FORMAT(trip.date, '%Y-%m-%d') <= '2019-05-02'


