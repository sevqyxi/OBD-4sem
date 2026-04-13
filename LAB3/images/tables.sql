DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'chamber_status') THEN
      CREATE TYPE chamber_status as ENUM ('Вільна', 'Зайнята');
  END IF;
END$$;

CREATE TABLE IF NOT EXISTS storage_unit
(
  chamber_id SERIAL PRIMARY KEY,
  storage_zone VARCHAR(6) NOT NULL,
  status chamber_status NOT NULL DEFAULT 'Вільна'

);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'staff_role') THEN
    CREATE TYPE staff_role as ENUM ('Лаборант', 'Судмедексперт');
    END IF;
END$$;

CREATE TABLE IF NOT EXISTS staff
(
    staff_id SERIAL PRIMARY KEY,
    id_passport_details VARCHAR(9) UNIQUE NOT NULL,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    role staff_role NOT NULL,
    specialization VARCHAR(40) NOT NULL,
    phone_number VARCHAR(12) UNIQUE NOT NULL,
    mail VARCHAR(64) UNIQUE NOT NULL
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'deceased_gender') THEN
      CREATE TYPE deceased_gender AS ENUM ('Жінка', 'Чоловік');
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'deceased_case_type') THEN
      CREATE TYPE deceased_case_type AS ENUM ('Природна смерть', 'Нещасний випадок',
                          'Вбивство', 'Самогубство', 'Причина невідома');
    END IF;
END$$;



CREATE TABLE IF NOT EXISTS deceased
(
    deceased_id SERIAL PRIMARY KEY,
    chamber_id INTEGER NOT NULL UNIQUE REFERENCES storage_unit(chamber_id) ON DELETE RESTRICT,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    id_passport_details VARCHAR(9) UNIQUE NOT NULL,
    date_of_birth DATE NOT NULL,
    date_of_death DATE NOT NULL,
    arrival_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gender deceased_gender NOT NULL,
    case_type deceased_case_type NOT NULL
);

CREATE TABLE IF NOT EXISTS relatives
(
    claimant_id SERIAL PRIMARY KEY,
    deceased_id INTEGER NOT NULL REFERENCES deceased(deceased_id) ON DELETE CASCADE,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    id_passport_details VARCHAR(9) UNIQUE NOT NULL,
    contact_phone VARCHAR(12) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS autopsy 
(
  autopsy_id SERIAL PRIMARY KEY,
  deceased_id INTEGER NOT NULL UNIQUE REFERENCES deceased(deceased_id) ON DELETE RESTRICT,
  staff_id INTEGER REFERENCES staff(staff_id),
  start_datetime TIMESTAMP,
  end_datetime TIMESTAMP,
  final_cause_of_death TEXT
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'laboratory_analysis_sample_type') THEN
      CREATE TYPE laboratory_analysis_sample_type AS ENUM 
    (
    'кров',
    'сеча',
    'тканина',
    'орган',
    'кістка',
    'вміст шлунка',
    'тканина легені',
    'тканина печінки',
    'тканина нирок',
    'тканина мозку',
    'волосся',
    'нігті'
    );
  END IF;
END$$;

DO $$
BEGIN
   IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'laboratory_analysis_test_type') THEN
      CREATE TYPE laboratory_analysis_test_type AS ENUM 
    (
    'токсикологічний',
    'гістологічний',
    'біохімічний',
    'мікробіологічний',
    'днк аналіз',
    'патологічний'
    );
   END IF;
END$$;

CREATE TABLE IF NOT EXISTS laboratory_analysis
(
  analysis_id SERIAL PRIMARY KEY,
  autopsy_id INTEGER NOT NULL REFERENCES autopsy(autopsy_id) ON DELETE RESTRICT,
  staff_id INTEGER NOT NULL REFERENCES staff(staff_id),
  sample_type laboratory_analysis_sample_type NOT NULL,
  test_type laboratory_analysis_test_type NOT NULL,
  result_summary TEXT
);

INSERT INTO storage_unit (storage_zone, status) VALUES
('A1', 'Зайнята'), ('A2', 'Зайнята'), ('A3', 'Зайнята'), ('A4', 'Зайнята'), ('A5', 'Зайнята'),
('A6', 'Зайнята'), ('A7', 'Зайнята'), ('A8', 'Зайнята'), ('A9', 'Зайнята'), ('A10', 'Зайнята'),
('B1', 'Зайнята'), ('B2', 'Зайнята'), ('B3', 'Вільна'),  ('B4', 'Вільна'),  ('B5', 'Вільна'),
('C1', 'Вільна'),  ('C2', 'Вільна'),  ('C3', 'Вільна'),  ('C4', 'Вільна'),  ('C5', 'Вільна');

INSERT INTO staff (id_passport_details, first_name, last_name, role, specialization, phone_number, mail) VALUES
('CA2326790', 'Віктор', 'Поцілуйко', 'Лаборант', '1-й ступінь', '380661487692', 'viktor.pociluyko1980@gmail.com'),
('AC1022901', 'Олег', 'Цвірінько', 'Лаборант', '2-й ступінь', '380951789011', 'olezha.cvirinko111@gmail.com'),
('BA1026899', 'Олександр', 'Костилєв', 'Судмедексперт', 'Професор', '380981114923', 'kostiloleks68@gmail.com'),
('AB4110014', 'Петро', 'Моставчук', 'Судмедексперт', 'Кандидат наук', '380681123007', 'petr.mostav71@gmail.com'),
('XX9998887', 'Анна', 'Коваленко', 'Лаборант', 'Вища категорія', '380509998877', 'anna.koval@gmail.com'),
('YY1112223', 'Іван', 'Марчук', 'Судмедексперт', 'Доцент', '380631112233', 'ivan.marchuk.med@gmail.com');

INSERT INTO deceased (chamber_id, first_name, last_name, id_passport_details, date_of_birth, date_of_death, arrival_datetime, gender, case_type) VALUES
(2, 'Саске', 'Пономаренко', 'KM1112223', '2026-03-15', '2026-03-16', '2026-03-16 20:41:59', 'Чоловік', 'Причина невідома'),
(4, 'Какаші', 'Хатаке', 'KM4445556', '1996-09-15', '2020-02-26', '2020-02-27 15:30:05', 'Чоловік', 'Вбивство'),
(5, 'Ерен', 'Йегер', 'KM7778889', '1990-10-07', '2024-03-18', '2024-03-19 17:20:35', 'Чоловік', 'Нещасний випадок'),
(1, 'Мікаса', 'Аккерман', 'KM0001112', '1989-12-03', '2025-07-02', '2025-07-02 18:30:35', 'Жінка', 'Природна смерть'),
(6, 'Василь', 'Стус', 'AA1112233', '1938-01-06', '2023-09-04', '2023-09-05 10:15:00', 'Чоловік', 'Природна смерть'),
(7, 'Леся', 'Українка', 'BB4445566', '1871-02-25', '2023-08-01', '2023-08-01 14:20:00', 'Жінка', 'Природна смерть'),
(8, 'Степан', 'Бандера', 'CC7778899', '1909-01-01', '2024-10-15', '2024-10-16 09:00:00', 'Чоловік', 'Вбивство'),
(9, 'Ліна', 'Костенко', 'DD0001122', '1930-03-19', '2026-01-10', '2026-01-10 22:45:00', 'Жінка', 'Природна смерть'),
(10, 'Тарас', 'Шевченко', 'EE3334455', '1814-03-09', '2022-03-10', '2022-03-11 11:30:00', 'Чоловік', 'Причина невідома'),
(11, 'Іван', 'Франко', 'FF6667788', '1856-08-27', '2025-05-28', '2025-05-28 16:50:00', 'Чоловік', 'Нещасний випадок'),
(12, 'Григорій', 'Сковорода', 'GG9990011', '1722-12-03', '2024-11-09', '2024-11-10 08:20:00', 'Чоловік', 'Самогубство'),
(3, 'Олена', 'Пчілка', 'HH2223344', '1849-06-29', '2023-10-04', '2023-10-05 12:10:00', 'Жінка', 'Природна смерть');

INSERT INTO relatives (deceased_id, first_name, last_name, id_passport_details, contact_phone) VALUES
(1, 'Ітачі', 'Пономаренко', 'AA1234567', '380671234567'),
(2, 'Сакумо', 'Хатаке', 'AA7654321', '380501234567'),
(3, 'Григорій', 'Йегер', 'BB1234567', '380931112233'),
(4, 'Леві', 'Аккерман', 'CC9876543', '380661234567'),
(3, 'Зік', 'Йегер', 'BB9998877', '380939998877'),
(5, 'Дмитро', 'Стус', 'KK1122334', '380671112233'),
(7, 'Ярослава', 'Бандера', 'LL5566778', '380502223344'),
(10, 'Михайло', 'Шевченко', 'MM9900112', '380633334455');

INSERT INTO autopsy (deceased_id, staff_id, start_datetime, end_datetime, final_cause_of_death) VALUES
(1, 3, '2026-03-18 12:14:57', '2026-03-18 15:31:10', 'Рак'),
(2, 4, '2020-02-29 11:29:15', '2020-02-29 16:10:28', 'Отруєння'),
(3, 3, '2024-03-21 09:18:00', '2024-03-21 11:23:09', 'Передозування алкоголем'),
(4, 4, '2025-07-04 10:00:00', '2025-07-04 12:16:49', 'Інсульт'),
(5, 6, '2023-09-06 09:00:00', '2023-09-06 13:45:00', 'Серцева недостатність'),
(7, 3, '2024-10-17 10:30:00', '2024-10-17 15:20:00', 'Вогнепальне поранення'),
(9, 4, '2022-03-12 11:00:00', '2022-03-12 14:10:00', 'Асфіксія'),
(10, 6, '2025-05-29 08:30:00', '2025-05-29 12:00:00', 'Черепно-мозкова травма'),
(11, 3, '2024-11-11 14:00:00', '2024-11-11 17:30:00', 'Внутрішня кровотеча');

INSERT INTO laboratory_analysis (autopsy_id, staff_id, sample_type, test_type, result_summary) VALUES
(1, 1, 'тканина', 'гістологічний', 'Ракова пухлина'),
(1, 5, 'кров', 'біохімічний', 'Підвищений рівень лейкоцитів'),
(2, 2, 'вміст шлунка', 'токсикологічний', 'Виявлено сліди ціаніду'),
(2, 1, 'кров', 'токсикологічний', 'Ціанід у крові'),
(3, 1, 'кров', 'токсикологічний', 'Етанол 3.5 проміле'),
(3, 2, 'сеча', 'токсикологічний', 'Етанол 4.0 проміле'),
(4, 2, 'тканина мозку', 'патологічний', 'Крововилив у мозок, розрив аневризми'),
(5, 5, 'орган', 'гістологічний', 'Ознаки обширного інфаркту міокарда'),
(6, 1, 'тканина', 'патологічний', 'Пошкодження внутрішніх органів кулею'),
(6, 5, 'кров', 'днк аналіз', 'Профіль ДНК збігається'),
(7, 2, 'тканина легені', 'гістологічний', 'Ознаки удушення'),
(8, 1, 'кістка', 'патологічний', 'Тріщина скроневої кістки'),
(9, 5, 'кров', 'токсикологічний', 'Токсичних речовин не виявлено'),
(9, 2, 'вміст шлунка', 'токсикологічний', 'Чисто');
