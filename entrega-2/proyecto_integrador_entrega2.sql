DROP TABLE IF EXISTS convocatoria;
DROP TABLE IF EXISTS partido;
DROP TABLE IF EXISTS torneo;
DROP TABLE IF EXISTS evaluacion_fisica;
DROP TABLE IF EXISTS lesion;
DROP TABLE IF EXISTS certificado_medico;
DROP TABLE IF EXISTS asistencia;
DROP TABLE IF EXISTS entrenamiento;
DROP TABLE IF EXISTS pago;
DROP TABLE IF EXISTS beca_inscripcion;
DROP TABLE IF EXISTS inscripcion;
DROP TABLE IF EXISTS horario_grupo;
DROP TABLE IF EXISTS grupo;
DROP TABLE IF EXISTS estudiante;
DROP TABLE IF EXISTS acudiente;
DROP TABLE IF EXISTS entrenador;
DROP TABLE IF EXISTS beca;
DROP TABLE IF EXISTS escenario;
DROP TABLE IF EXISTS categoria;
DROP TABLE IF EXISTS deporte;
DROP TABLE IF EXISTS persona;


CREATE TABLE persona (
    id_persona       INTEGER       NOT NULL,
    tipo_documento   VARCHAR(5)    NOT NULL,
    num_documento    VARCHAR(20)   NOT NULL,
    nombres          VARCHAR(100)  NOT NULL,
    apellidos        VARCHAR(100)  NOT NULL,
    fecha_nacimiento DATE          NOT NULL,
    genero           VARCHAR(10)   NOT NULL,
    rh               VARCHAR(3),
    eps              VARCHAR(100),
    telefono         VARCHAR(20)   NOT NULL,
    correo           VARCHAR(100),
    direccion        VARCHAR(150)  NOT NULL,
    estado           VARCHAR(10)   NOT NULL DEFAULT 'ACTIVO',
    fecha_registro   TIMESTAMP     NOT NULL,
    CONSTRAINT pk_persona PRIMARY KEY (id_persona),
    -- RN-01: una persona no se registra dos veces
    CONSTRAINT uq_persona_documento UNIQUE (tipo_documento, num_documento),
    CONSTRAINT ck_persona_tipo_documento CHECK ((tipo_documento = 'RC' OR tipo_documento = 'TI' OR tipo_documento = 'CC' OR tipo_documento = 'CE' OR tipo_documento = 'PP')),
    CONSTRAINT ck_persona_genero CHECK ((genero = 'MASCULINO' OR genero = 'FEMENINO' OR genero = 'OTRO')),
    CONSTRAINT ck_persona_rh CHECK ((rh = 'A+' OR rh = 'A-' OR rh = 'B+' OR rh = 'B-' OR rh = 'AB+' OR rh = 'AB-' OR rh = 'O+' OR rh = 'O-')),
    -- RN-03: borrado lógico
    CONSTRAINT ck_persona_estado CHECK ((estado = 'ACTIVO' OR estado = 'INACTIVO'))
);

CREATE TABLE entrenador (
    id_entrenador       INTEGER        NOT NULL,
    salario             NUMERIC(12,2)  NOT NULL,
    fecha_ingreso       DATE           NOT NULL,
    nivel_certificacion VARCHAR(100)   NOT NULL,
    estado              VARCHAR(10)    NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT pk_entrenador PRIMARY KEY (id_entrenador),
    CONSTRAINT fk_entrenador_persona FOREIGN KEY (id_entrenador)
        REFERENCES persona (id_persona) ON DELETE RESTRICT,
    CONSTRAINT ck_entrenador_salario CHECK (salario > 0),
    CONSTRAINT ck_entrenador_estado CHECK ((estado = 'ACTIVO' OR estado = 'INACTIVO'))
);

CREATE TABLE acudiente (
    id_acudiente     INTEGER      NOT NULL,
    ocupacion        VARCHAR(100),
    telefono_alterno VARCHAR(20),
    CONSTRAINT pk_acudiente PRIMARY KEY (id_acudiente),
    CONSTRAINT fk_acudiente_persona FOREIGN KEY (id_acudiente)
        REFERENCES persona (id_persona) ON DELETE RESTRICT
);

CREATE TABLE estudiante (
    id_estudiante        INTEGER      NOT NULL,
    id_acudiente         INTEGER,
    parentesco_acudiente VARCHAR(50),
    fecha_ingreso_club   DATE         NOT NULL,
    estado               VARCHAR(10)  NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT pk_estudiante PRIMARY KEY (id_estudiante),
    CONSTRAINT fk_estudiante_persona FOREIGN KEY (id_estudiante)
        REFERENCES persona (id_persona) ON DELETE RESTRICT,
    CONSTRAINT fk_estudiante_acudiente FOREIGN KEY (id_acudiente)
        REFERENCES acudiente (id_acudiente) ON DELETE RESTRICT,
    -- RN-02: acudiente y parentesco van juntos; nadie es su propio acudiente
    CONSTRAINT ck_estudiante_acudiente CHECK (
        (id_acudiente IS NULL AND parentesco_acudiente IS NULL)
        OR (id_acudiente IS NOT NULL AND parentesco_acudiente IS NOT NULL
            AND (id_acudiente < id_estudiante OR id_acudiente > id_estudiante))),
    CONSTRAINT ck_estudiante_estado CHECK ((estado = 'ACTIVO' OR estado = 'INACTIVO'))
);


CREATE TABLE deporte (
    id_deporte INTEGER      NOT NULL,
    nombre     VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_deporte PRIMARY KEY (id_deporte),
    CONSTRAINT uq_deporte_nombre UNIQUE (nombre)
);

CREATE TABLE categoria (
    id_categoria INTEGER      NOT NULL,
    nombre       VARCHAR(50)  NOT NULL,
    edad_minima  SMALLINT     NOT NULL,
    edad_maxima  SMALLINT     NOT NULL,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre),
    -- RN-07: edades entre 6 y 20, mínima <= máxima
    CONSTRAINT ck_categoria_edades CHECK (
        (edad_minima >= 6 AND edad_minima <= 20)
        AND (edad_maxima >= 6 AND edad_maxima <= 20)
        AND edad_minima <= edad_maxima)
);

CREATE TABLE escenario (
    id_escenario   INTEGER       NOT NULL,
    nombre         VARCHAR(100)  NOT NULL,
    tipo_escenario VARCHAR(50)   NOT NULL,
    ubicacion      VARCHAR(150)  NOT NULL,
    estado         VARCHAR(10)   NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT pk_escenario PRIMARY KEY (id_escenario),
    CONSTRAINT uq_escenario_nombre UNIQUE (nombre),
    CONSTRAINT ck_escenario_estado CHECK ((estado = 'ACTIVO' OR estado = 'INACTIVO'))
);

CREATE TABLE grupo (
    id_grupo      INTEGER      NOT NULL,
    id_deporte    INTEGER      NOT NULL,
    id_categoria  INTEGER      NOT NULL,
    id_entrenador INTEGER      NOT NULL,   
    nombre        VARCHAR(60)  NOT NULL,
    cupo_maximo   SMALLINT     NOT NULL,
    estado        VARCHAR(10)  NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT pk_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT fk_grupo_deporte FOREIGN KEY (id_deporte)
        REFERENCES deporte (id_deporte) ON DELETE RESTRICT,
    CONSTRAINT fk_grupo_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria) ON DELETE RESTRICT,
    CONSTRAINT fk_grupo_entrenador FOREIGN KEY (id_entrenador)
        REFERENCES entrenador (id_entrenador) ON DELETE RESTRICT,
    -- RN-05: no se repite el nombre del grupo en la misma combinación
    CONSTRAINT uq_grupo_nombre UNIQUE (id_deporte, id_categoria, nombre),
    CONSTRAINT ck_grupo_cupo CHECK (cupo_maximo > 0),
    CONSTRAINT ck_grupo_estado CHECK ((estado = 'ACTIVO' OR estado = 'INACTIVO'))
);

CREATE TABLE horario_grupo (
    id_horario        INTEGER   NOT NULL,
    id_grupo          INTEGER   NOT NULL,
    id_escenario      INTEGER   NOT NULL,
    dia_semana        SMALLINT  NOT NULL,
    hora_inicio       TIME      NOT NULL,
    hora_finalizacion TIME      NOT NULL,
    CONSTRAINT pk_horario_grupo PRIMARY KEY (id_horario),
    -- El horario no tiene sentido sin su grupo
    CONSTRAINT fk_horario_grupo FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo) ON DELETE CASCADE,
    CONSTRAINT fk_horario_escenario FOREIGN KEY (id_escenario)
        REFERENCES escenario (id_escenario) ON DELETE RESTRICT,
    CONSTRAINT uq_horario_grupo_dia UNIQUE (id_grupo, dia_semana, hora_inicio),
    -- RN-15: 1 = lunes ... 7 = domingo
    CONSTRAINT ck_horario_dia CHECK ((dia_semana >= 1 AND dia_semana <= 7)),
    -- RN-14
    CONSTRAINT ck_horario_horas CHECK (hora_finalizacion > hora_inicio)
);


CREATE TABLE beca (
    id_beca              INTEGER       NOT NULL,
    nombre               VARCHAR(80)   NOT NULL,
    tipo_beca            VARCHAR(20)   NOT NULL,
    porcentaje_descuento NUMERIC(5,2)  NOT NULL,
    descripcion          VARCHAR(200),
    estado               VARCHAR(10)   NOT NULL DEFAULT 'ACTIVA',
    CONSTRAINT pk_beca PRIMARY KEY (id_beca),
    CONSTRAINT uq_beca_nombre UNIQUE (nombre),
    CONSTRAINT ck_beca_tipo CHECK ((tipo_beca = 'DEPORTIVA' OR tipo_beca = 'SOCIOECONOMICA' OR tipo_beca = 'HERMANOS' OR tipo_beca = 'OTRA')),
    -- RN-27: mayor que 0 y no superior a 90
    CONSTRAINT ck_beca_porcentaje CHECK (porcentaje_descuento > 0 AND porcentaje_descuento <= 90),
    CONSTRAINT ck_beca_estado CHECK ((estado = 'ACTIVA' OR estado = 'INACTIVA'))
);


CREATE TABLE inscripcion (
    id_inscripcion      INTEGER        NOT NULL,
    id_estudiante       INTEGER        NOT NULL,
    id_grupo            INTEGER        NOT NULL,
    fecha_inscripcion   DATE           NOT NULL,
    fecha_finalizacion  DATE,
    mensualidad_pactada NUMERIC(12,2)  NOT NULL,
    estado              VARCHAR(12)    NOT NULL DEFAULT 'ACTIVA',
    CONSTRAINT pk_inscripcion PRIMARY KEY (id_inscripcion),
    CONSTRAINT fk_inscripcion_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES estudiante (id_estudiante) ON DELETE RESTRICT,
    CONSTRAINT fk_inscripcion_grupo FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo) ON DELETE RESTRICT,
    CONSTRAINT ck_inscripcion_mensualidad CHECK (mensualidad_pactada > 0),
    CONSTRAINT ck_inscripcion_estado CHECK ((estado = 'ACTIVA' OR estado = 'FINALIZADA' OR estado = 'CANCELADA')),
    -- RN-08: fin no anterior al inicio; obligatoria si no está ACTIVA
    CONSTRAINT ck_inscripcion_fechas CHECK (
        (fecha_finalizacion IS NULL OR fecha_finalizacion >= fecha_inscripcion)
        AND (estado = 'ACTIVA' OR fecha_finalizacion IS NOT NULL))
);

-- resuelve la relación muchos a muchos BECA - INSCRIPCION
CREATE TABLE beca_inscripcion (
    id_beca_inscripcion INTEGER      NOT NULL,
    id_inscripcion      INTEGER      NOT NULL,
    id_beca             INTEGER      NOT NULL,
    fecha_inicio        DATE         NOT NULL,
    fecha_fin           DATE,
    estado              VARCHAR(10)  NOT NULL DEFAULT 'VIGENTE',
    observaciones       VARCHAR(200),
    CONSTRAINT pk_beca_inscripcion PRIMARY KEY (id_beca_inscripcion),
    -- RN-30: las becas no se borran
    CONSTRAINT fk_beca_insc_inscripcion FOREIGN KEY (id_inscripcion)
        REFERENCES inscripcion (id_inscripcion) ON DELETE RESTRICT,
    CONSTRAINT fk_beca_insc_beca FOREIGN KEY (id_beca)
        REFERENCES beca (id_beca) ON DELETE RESTRICT,
    CONSTRAINT ck_beca_insc_estado CHECK ((estado = 'VIGENTE' OR estado = 'FINALIZADA' OR estado = 'REVOCADA')),
    -- RN-28
    CONSTRAINT ck_beca_insc_fechas CHECK (
        (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
        AND (estado = 'VIGENTE' OR fecha_fin IS NOT NULL))
);

CREATE TABLE pago (
    id_pago             INTEGER        NOT NULL,
    id_inscripcion      INTEGER        NOT NULL,
    id_beca_inscripcion INTEGER,
    periodo_anio        SMALLINT       NOT NULL,
    periodo_mes         SMALLINT       NOT NULL,
    valor               NUMERIC(12,2)  NOT NULL,
    valor_descuento     NUMERIC(12,2)  NOT NULL DEFAULT 0,
    fecha_vencimiento   DATE           NOT NULL,
    fecha_pago          DATE,
    metodo_pago         VARCHAR(15),
    estado              VARCHAR(10)    NOT NULL DEFAULT 'PENDIENTE',
    CONSTRAINT pk_pago PRIMARY KEY (id_pago),
    -- RN-13: el historial financiero no se borra en cadena
    CONSTRAINT fk_pago_inscripcion FOREIGN KEY (id_inscripcion)
        REFERENCES inscripcion (id_inscripcion) ON DELETE RESTRICT,
    CONSTRAINT fk_pago_beca_inscripcion FOREIGN KEY (id_beca_inscripcion)
        REFERENCES beca_inscripcion (id_beca_inscripcion) ON DELETE RESTRICT,
    -- RN-09: no se cobra dos veces el mismo período
    CONSTRAINT uq_pago_periodo UNIQUE (id_inscripcion, periodo_anio, periodo_mes),
    CONSTRAINT ck_pago_anio CHECK (periodo_anio > 0),
    CONSTRAINT ck_pago_mes CHECK ((periodo_mes >= 1 AND periodo_mes <= 12)),
    -- RN-10
    CONSTRAINT ck_pago_valor CHECK (valor > 0),
    CONSTRAINT ck_pago_descuento CHECK (valor_descuento >= 0),
    CONSTRAINT ck_pago_metodo CHECK ((metodo_pago = 'EFECTIVO' OR metodo_pago = 'TRANSFERENCIA' OR metodo_pago = 'TARJETA')),
    CONSTRAINT ck_pago_estado CHECK ((estado = 'PENDIENTE' OR estado = 'PAGADO' OR estado = 'VENCIDO' OR estado = 'ANULADO')),
    -- RN-29: con descuento hay beca aplicada
    CONSTRAINT ck_pago_beca CHECK (valor_descuento = 0 OR id_beca_inscripcion IS NOT NULL),
    -- RN-11: PAGADO exige fecha y método; PENDIENTE/VENCIDO no los tienen; ANULADO conserva lo que tenía
    CONSTRAINT ck_pago_estado_datos CHECK (
        (estado = 'PAGADO' AND fecha_pago IS NOT NULL AND metodo_pago IS NOT NULL)
        OR ((estado = 'PENDIENTE' OR estado = 'VENCIDO') AND fecha_pago IS NULL AND metodo_pago IS NULL)
        OR estado = 'ANULADO')
);


CREATE TABLE entrenamiento (
    id_entrenamiento  INTEGER       NOT NULL,
    id_grupo          INTEGER       NOT NULL,   
    id_entrenador     INTEGER       NOT NULL,
    id_escenario      INTEGER       NOT NULL,
    fecha             DATE          NOT NULL,
    hora_inicio       TIME          NOT NULL,
    hora_finalizacion TIME          NOT NULL,
    estado            VARCHAR(12)   NOT NULL DEFAULT 'PROGRAMADO',
    observaciones     VARCHAR(200),
    CONSTRAINT pk_entrenamiento PRIMARY KEY (id_entrenamiento),
    CONSTRAINT fk_entren_grupo FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo) ON DELETE RESTRICT,
    CONSTRAINT fk_entren_entrenador FOREIGN KEY (id_entrenador)
        REFERENCES entrenador (id_entrenador) ON DELETE RESTRICT,
    CONSTRAINT fk_entren_escenario FOREIGN KEY (id_escenario)
        REFERENCES escenario (id_escenario) ON DELETE RESTRICT,
    CONSTRAINT ck_entren_horas CHECK (hora_finalizacion > hora_inicio),  -- RN-14
    CONSTRAINT ck_entren_estado CHECK ((estado = 'PROGRAMADO' OR estado = 'REALIZADO' OR estado = 'CANCELADO'))
);


CREATE TABLE asistencia (
    id_asistencia     INTEGER      NOT NULL,
    id_inscripcion    INTEGER      NOT NULL,
    id_entrenamiento  INTEGER      NOT NULL,
    estado_asistencia VARCHAR(12)  NOT NULL,
    fecha_registro    TIMESTAMP    NOT NULL,
    CONSTRAINT pk_asistencia PRIMARY KEY (id_asistencia),
    -- La asistencia no tiene valor sin su inscripción ni su sesión
    CONSTRAINT fk_asist_inscripcion FOREIGN KEY (id_inscripcion)
        REFERENCES inscripcion (id_inscripcion) ON DELETE CASCADE,
    CONSTRAINT fk_asist_entrenamiento FOREIGN KEY (id_entrenamiento)
        REFERENCES entrenamiento (id_entrenamiento) ON DELETE CASCADE,
    -- RN-16
    CONSTRAINT uq_asistencia UNIQUE (id_inscripcion, id_entrenamiento),
    CONSTRAINT ck_asist_estado CHECK ((estado_asistencia = 'ASISTIO' OR estado_asistencia = 'FALTO' OR estado_asistencia = 'JUSTIFICADO'))
);


CREATE TABLE certificado_medico (
    id_certificado    INTEGER       NOT NULL,
    id_estudiante     INTEGER       NOT NULL,
    fecha_expedicion  DATE          NOT NULL,
    fecha_vencimiento DATE          NOT NULL,
    entidad_emisora   VARCHAR(100)  NOT NULL,
    concepto          VARCHAR(25)   NOT NULL,
    restricciones     VARCHAR(200),
    estado            VARCHAR(10)   NOT NULL DEFAULT 'VIGENTE',
    CONSTRAINT pk_certificado PRIMARY KEY (id_certificado),
    CONSTRAINT fk_cert_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES estudiante (id_estudiante) ON DELETE RESTRICT,
    CONSTRAINT ck_cert_concepto CHECK ((concepto = 'APTO' OR concepto = 'APTO_CON_RESTRICCIONES' OR concepto = 'NO_APTO')),
    CONSTRAINT ck_cert_estado CHECK ((estado = 'VIGENTE' OR estado = 'ANULADO')),
    -- RN-19
    CONSTRAINT ck_cert_fechas CHECK (fecha_vencimiento > fecha_expedicion),
    CONSTRAINT ck_cert_restricciones CHECK (
        (concepto = 'APTO' OR concepto = 'NO_APTO' OR restricciones IS NOT NULL))
);

CREATE TABLE lesion (
    id_lesion        INTEGER       NOT NULL,
    id_estudiante    INTEGER       NOT NULL,
    id_entrenamiento INTEGER,
    fecha_lesion     DATE          NOT NULL,
    tipo_lesion      VARCHAR(60)   NOT NULL,
    gravedad         VARCHAR(10)   NOT NULL,
    descripcion      VARCHAR(250),
    fecha_alta       DATE,
    estado           VARCHAR(15)   NOT NULL DEFAULT 'EN_TRATAMIENTO',
    CONSTRAINT pk_lesion PRIMARY KEY (id_lesion),
    CONSTRAINT fk_lesion_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES estudiante (id_estudiante) ON DELETE RESTRICT,
    CONSTRAINT fk_lesion_entrenamiento FOREIGN KEY (id_entrenamiento)
        REFERENCES entrenamiento (id_entrenamiento) ON DELETE RESTRICT,
    CONSTRAINT ck_lesion_gravedad CHECK ((gravedad = 'LEVE' OR gravedad = 'MODERADA' OR gravedad = 'GRAVE')),
    CONSTRAINT ck_lesion_estado CHECK ((estado = 'EN_TRATAMIENTO' OR estado = 'RECUPERADO')),
    -- RN-20: alta no anterior a la lesión; obligatoria si RECUPERADO y nula si EN_TRATAMIENTO
    CONSTRAINT ck_lesion_alta CHECK (
        (fecha_alta IS NULL OR fecha_alta >= fecha_lesion)
        AND ((estado = 'RECUPERADO' AND fecha_alta IS NOT NULL)
             OR (estado = 'EN_TRATAMIENTO' AND fecha_alta IS NULL)))
);

CREATE TABLE evaluacion_fisica (
    id_evaluacion     INTEGER       NOT NULL,
    id_estudiante     INTEGER       NOT NULL,
    id_entrenador     INTEGER       NOT NULL,
    fecha_evaluacion  DATE          NOT NULL,
    peso_kg           NUMERIC(5,2)  NOT NULL,
    estatura_cm       SMALLINT      NOT NULL,
    frecuencia_reposo SMALLINT,
    observaciones     VARCHAR(250),
    CONSTRAINT pk_evaluacion PRIMARY KEY (id_evaluacion),
    CONSTRAINT fk_eval_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES estudiante (id_estudiante) ON DELETE RESTRICT,
    CONSTRAINT fk_eval_entrenador FOREIGN KEY (id_entrenador)
        REFERENCES entrenador (id_entrenador) ON DELETE RESTRICT,
    -- RN-21: una evaluación por deportista y fecha, con rangos válidos
    CONSTRAINT uq_eval_estudiante_fecha UNIQUE (id_estudiante, fecha_evaluacion),
    CONSTRAINT ck_eval_peso CHECK ((peso_kg >= 10 AND peso_kg <= 200)),
    CONSTRAINT ck_eval_estatura CHECK ((estatura_cm >= 80 AND estatura_cm <= 230)),
    CONSTRAINT ck_eval_frecuencia CHECK ((frecuencia_reposo >= 30 AND frecuencia_reposo <= 220))
);


CREATE TABLE torneo (
    id_torneo    INTEGER       NOT NULL,
    id_deporte   INTEGER       NOT NULL,
    id_categoria INTEGER       NOT NULL,
    nombre       VARCHAR(100)  NOT NULL,
    tipo_torneo  VARCHAR(10)   NOT NULL,
    sede         VARCHAR(150),
    fecha_inicio DATE          NOT NULL,
    fecha_fin    DATE          NOT NULL,
    estado       VARCHAR(12)   NOT NULL DEFAULT 'PROGRAMADO',
    CONSTRAINT pk_torneo PRIMARY KEY (id_torneo),
    CONSTRAINT fk_torneo_deporte FOREIGN KEY (id_deporte)
        REFERENCES deporte (id_deporte) ON DELETE RESTRICT,
    CONSTRAINT fk_torneo_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria) ON DELETE RESTRICT,
    -- RN-22
    CONSTRAINT uq_torneo_nombre_inicio UNIQUE (nombre, fecha_inicio),
    CONSTRAINT ck_torneo_fechas CHECK (fecha_fin >= fecha_inicio),
    CONSTRAINT ck_torneo_tipo CHECK ((tipo_torneo = 'INTERNO' OR tipo_torneo = 'EXTERNO' OR tipo_torneo = 'AMISTOSO')),
    CONSTRAINT ck_torneo_estado CHECK ((estado = 'PROGRAMADO' OR estado = 'EN_CURSO' OR estado = 'FINALIZADO' OR estado = 'CANCELADO'))
);

CREATE TABLE partido (
    id_partido        INTEGER       NOT NULL,
    id_torneo         INTEGER       NOT NULL,
    id_grupo          INTEGER       NOT NULL,
    id_escenario      INTEGER,
    rival             VARCHAR(100)  NOT NULL,
    condicion         VARCHAR(10)   NOT NULL,
    fecha             DATE          NOT NULL,
    hora_inicio       TIME          NOT NULL,
    hora_finalizacion TIME          NOT NULL,
    puntos_favor      SMALLINT,
    puntos_contra     SMALLINT,
    estado            VARCHAR(12)   NOT NULL DEFAULT 'PROGRAMADO',
    CONSTRAINT pk_partido PRIMARY KEY (id_partido),
    CONSTRAINT fk_partido_torneo FOREIGN KEY (id_torneo)
        REFERENCES torneo (id_torneo) ON DELETE RESTRICT,
    CONSTRAINT fk_partido_grupo FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo) ON DELETE RESTRICT,
    CONSTRAINT fk_partido_escenario FOREIGN KEY (id_escenario)
        REFERENCES escenario (id_escenario) ON DELETE RESTRICT,
    CONSTRAINT ck_partido_condicion CHECK ((condicion = 'LOCAL' OR condicion = 'VISITANTE')),
    CONSTRAINT ck_partido_estado CHECK ((estado = 'PROGRAMADO' OR estado = 'JUGADO' OR estado = 'APLAZADO' OR estado = 'CANCELADO')),
    CONSTRAINT ck_partido_puntos CHECK (puntos_favor >= 0 AND puntos_contra >= 0),
    -- RN-23: LOCAL con escenario, VISITANTE sin escenario; horas en orden
    CONSTRAINT ck_partido_escenario CHECK (
        (condicion = 'LOCAL' AND id_escenario IS NOT NULL)
        OR (condicion = 'VISITANTE' AND id_escenario IS NULL)),
    CONSTRAINT ck_partido_horas CHECK (hora_finalizacion > hora_inicio),
    -- RN-24: JUGADO exige marcador; en otro estado el marcador es nulo
    CONSTRAINT ck_partido_marcador CHECK (
        (estado = 'JUGADO' AND puntos_favor IS NOT NULL AND puntos_contra IS NOT NULL)
        OR ((estado = 'PROGRAMADO' OR estado = 'APLAZADO' OR estado = 'CANCELADO') AND puntos_favor IS NULL AND puntos_contra IS NULL))
);


CREATE TABLE convocatoria (
    id_convocatoria INTEGER      NOT NULL,
    id_partido      INTEGER      NOT NULL,
    id_inscripcion  INTEGER      NOT NULL,
    es_titular      BOOLEAN      NOT NULL DEFAULT FALSE,
    minutos_jugados SMALLINT,
    observaciones   VARCHAR(200),
    CONSTRAINT pk_convocatoria PRIMARY KEY (id_convocatoria),
    -- La convocatoria no tiene sentido sin su partido
    CONSTRAINT fk_convoc_partido FOREIGN KEY (id_partido)
        REFERENCES partido (id_partido) ON DELETE CASCADE,
    CONSTRAINT fk_convoc_inscripcion FOREIGN KEY (id_inscripcion)
        REFERENCES inscripcion (id_inscripcion) ON DELETE RESTRICT,
    -- RN-25
    CONSTRAINT uq_convocatoria UNIQUE (id_partido, id_inscripcion),
    -- RN-26
    CONSTRAINT ck_convoc_minutos CHECK ((minutos_jugados >= 0 AND minutos_jugados <= 120))
);

INSERT INTO persona (id_persona, tipo_documento, num_documento, nombres, apellidos, fecha_nacimiento, genero, rh, eps, telefono, correo, direccion, estado, fecha_registro) VALUES
(1,  'CC', '1065001001', 'Carlos Andrés',  'Mejía Pérez',      '1985-03-12', 'MASCULINO', 'O+',  'Nueva EPS',  '3001112201', 'carlos.mejia@club300.co',   'Cra 9 # 12-34, Valledupar',  'ACTIVO', '2026-01-05 08:00:00'),
(2,  'CC', '1065001002', 'Laura Marcela',  'Ortiz Díaz',       '1990-07-21', 'FEMENINO',  'A+',  'Sanitas',    '3001112202', 'laura.ortiz@club300.co',    'Calle 15 # 7-20, Valledupar','ACTIVO', '2026-01-05 08:10:00'),
(3,  'CC', '1065001003', 'Julián David',   'Romero Cuello',    '1988-11-05', 'MASCULINO', 'B+',  'Salud Total','3001112203', 'julian.romero@club300.co',  'Cra 12 # 20-15, Valledupar', 'ACTIVO', '2026-01-05 08:20:00'),
(4,  'CC', '1065001004', 'Andrea Paola',   'Vega Serna',       '1992-01-30', 'FEMENINO',  'O-',  'Nueva EPS',  '3001112204', 'andrea.vega@club300.co',    'Calle 6 # 14-08, Valledupar','ACTIVO', '2026-01-05 08:30:00'),
(5,  'CC', '1065001005', 'Ricardo Luis',   'Fuentes Maestre',  '1983-09-18', 'MASCULINO', 'A-',  'Sanitas',    '3001112205', 'ricardo.fuentes@club300.co','Cra 19 # 9-41, Valledupar',  'ACTIVO', '2026-01-05 08:40:00'),
(11, 'CC', '1065002011', 'Marta Lucía',    'Castro Rojas',     '1980-04-02', 'FEMENINO',  'O+',  'Salud Total','3012223311', 'marta.castro@correo.com',   'Cra 5 # 18-22, Valledupar',  'ACTIVO', '2026-01-10 09:00:00'),
(12, 'CC', '1065002012', 'Pedro Pablo',    'Daza Molina',      '1978-12-14', 'MASCULINO', 'A+',  'Nueva EPS',  '3012223312', 'pedro.daza@correo.com',     'Calle 21 # 4-16, Valledupar','ACTIVO', '2026-01-10 09:10:00'),
(13, 'CC', '1065002013', 'Sandra Milena',  'Peñaranda Ruiz',   '1984-06-25', 'FEMENINO',  'B+',  'Sanitas',    '3012223313', 'sandra.penaranda@correo.com','Cra 8 # 25-30, Valledupar', 'ACTIVO', '2026-01-10 09:20:00'),
(14, 'CC', '1065002014', 'Hernán Darío',   'Quintero Oñate',   '1975-08-09', 'MASCULINO', 'O+',  'Salud Total','3012223314', 'hernan.quintero@correo.com','Calle 10 # 11-05, Valledupar','ACTIVO','2026-01-10 09:30:00'),
(15, 'CC', '1065002015', 'Gloria Inés',    'Barros Linares',   '1982-02-17', 'FEMENINO',  'AB+', 'Nueva EPS',  '3012223315', NULL,                        'Cra 14 # 6-12, Valledupar',  'ACTIVO', '2026-01-10 09:40:00'),
(21, 'TI', '1100200021', 'Mateo',          'Pérez Castro',     '2014-05-10', 'MASCULINO', 'O+',  'Salud Total','3012223311', NULL,                        'Cra 5 # 18-22, Valledupar',  'ACTIVO', '2026-01-15 10:00:00'),
(22, 'TI', '1100200022', 'Valentina',      'Pérez Castro',     '2016-08-22', 'FEMENINO',  'O+',  'Salud Total','3012223311', NULL,                        'Cra 5 # 18-22, Valledupar',  'ACTIVO', '2026-01-15 10:05:00'),
(23, 'TI', '1100200023', 'Santiago',       'Daza Molina',      '2012-02-17', 'MASCULINO', 'A+',  'Nueva EPS',  '3012223312', NULL,                        'Calle 21 # 4-16, Valledupar','ACTIVO', '2026-02-01 10:00:00'),
(24, 'TI', '1100200024', 'Isabella',       'Ruiz Peñaranda',   '2010-10-09', 'FEMENINO',  'B+',  'Sanitas',    '3012223313', NULL,                        'Cra 8 # 25-30, Valledupar',  'ACTIVO', '2026-02-01 10:10:00'),
(25, 'TI', '1100200025', 'Samuel',         'Quintero Oñate',   '2009-06-15', 'MASCULINO', 'O+',  'Salud Total','3012223314', NULL,                        'Calle 10 # 11-05, Valledupar','ACTIVO','2026-01-20 10:00:00'),
(26, 'CC', '1065002026', 'Daniela',        'Mejía Torres',     '2007-03-03', 'FEMENINO',  'A-',  'Sanitas',    '3012223326', 'daniela.mejia@correo.com',  'Cra 3 # 13-27, Valledupar',  'ACTIVO', '2026-03-01 10:00:00'),
(27, 'RC', '1100200027', 'Emilio',         'Charris Lobo',     '2018-01-25', 'MASCULINO', 'B-',  'Nueva EPS',  '3012223313', NULL,                        'Cra 8 # 25-30, Valledupar',  'ACTIVO', '2026-01-15 10:15:00');


INSERT INTO entrenador (id_entrenador, salario, fecha_ingreso, nivel_certificacion, estado) VALUES
(1, 2800000.00, '2020-02-01', 'Entrenador Nivel 3 de Fútbol',        'ACTIVO'),
(2, 2600000.00, '2021-03-15', 'Entrenador Nivel 2 de Baloncesto',    'ACTIVO'),
(3, 2500000.00, '2022-01-10', 'Entrenador Nivel 2 de Voleibol',      'ACTIVO'),
(4, 2700000.00, '2019-08-20', 'Instructor Certificado de Tenis',     'ACTIVO'),
(5, 2400000.00, '2023-05-02', 'Entrenador Nivel 1 de Fútbol Infantil','ACTIVO');


INSERT INTO acudiente (id_acudiente, ocupacion, telefono_alterno) VALUES
(11, 'Contadora',    '3104445511'),
(12, 'Ingeniero',    '3104445512'),
(13, 'Docente',      '3104445513'),
(14, 'Comerciante',  NULL),
(15, 'Enfermera',    '3104445515');


INSERT INTO estudiante (id_estudiante, id_acudiente, parentesco_acudiente, fecha_ingreso_club, estado) VALUES
(21, 11,   'madre', '2026-01-15', 'ACTIVO'),
(22, 11,   'madre', '2026-01-15', 'ACTIVO'),
(23, 12,   'padre', '2026-02-01', 'ACTIVO'),
(24, 13,   'madre', '2026-02-01', 'ACTIVO'),
(25, 14,   'padre', '2026-01-20', 'ACTIVO'),
(26, NULL, NULL,    '2026-03-01', 'ACTIVO'),
(27, 13,   'tía',   '2026-01-15', 'ACTIVO');


INSERT INTO deporte (id_deporte, nombre) VALUES
(1, 'Fútbol'),
(2, 'Baloncesto'),
(3, 'Voleibol'),
(4, 'Tenis'),
(5, 'Atletismo');


INSERT INTO categoria (id_categoria, nombre, edad_minima, edad_maxima) VALUES
(1, 'Sub-8',   6,  8),
(2, 'Sub-10',  9,  10),
(3, 'Sub-12',  11, 12),
(4, 'Sub-14',  13, 14),
(5, 'Sub-16',  15, 16),
(6, 'Sub-18',  17, 18),
(7, 'Sub-20',  19, 20);


INSERT INTO escenario (id_escenario, nombre, tipo_escenario, ubicacion, estado) VALUES
(1, 'Cancha Sintética Principal', 'Cancha de fútbol',     'Sede Principal, Valledupar', 'ACTIVO'),
(2, 'Cancha Múltiple Norte',      'Cancha múltiple',      'Sede Norte, Valledupar',     'ACTIVO'),
(3, 'Coliseo Cubierto',           'Coliseo',              'Sede Principal, Valledupar', 'ACTIVO'),
(4, 'Cancha de Tenis 1',          'Cancha de tenis',      'Sede Principal, Valledupar', 'ACTIVO'),
(5, 'Cancha Auxiliar',            'Cancha de entrenamiento','Sede Norte, Valledupar',   'INACTIVO');


INSERT INTO grupo (id_grupo, id_deporte, id_categoria, id_entrenador, nombre, cupo_maximo, estado) VALUES
(1, 1, 3, 1, 'Fútbol Sub-12 A',     20, 'ACTIVO'),
(2, 2, 2, 2, 'Baloncesto Sub-10 A', 15, 'ACTIVO'),
(3, 3, 5, 3, 'Voleibol Sub-16 A',   14, 'ACTIVO'),
(4, 4, 4, 4, 'Tenis Sub-14 A',       8, 'ACTIVO'),
(5, 1, 6, 1, 'Fútbol Sub-18 A',     22, 'ACTIVO'),
(6, 1, 1, 5, 'Fútbol Sub-8 A',      18, 'ACTIVO'),
(7, 2, 7, 2, 'Baloncesto Sub-20 A', 12, 'ACTIVO');


INSERT INTO horario_grupo (id_horario, id_grupo, id_escenario, dia_semana, hora_inicio, hora_finalizacion) VALUES
(1, 1, 1, 2, '16:00', '17:30'),
(2, 1, 1, 4, '16:00', '17:30'),
(3, 2, 3, 1, '15:00', '16:30'),
(4, 3, 3, 3, '17:00', '18:30'),
(5, 4, 4, 5, '15:30', '17:00'),
(6, 5, 1, 2, '18:00', '19:30'),
(7, 6, 2, 6, '09:00', '10:30');


INSERT INTO beca (id_beca, nombre, tipo_beca, porcentaje_descuento, descripcion, estado) VALUES
(1, 'Beca Deportiva Élite',       'DEPORTIVA',      50.00, 'Para deportistas con resultados destacados.',  'ACTIVA'),
(2, 'Beca Socioeconómica',        'SOCIOECONOMICA', 30.00, 'Según estudio socioeconómico de la familia.',  'ACTIVA'),
(3, 'Descuento por Hermanos',     'HERMANOS',       15.00, 'Cuando dos o más hermanos están inscritos.',   'ACTIVA'),
(4, 'Beca Rendimiento Académico', 'OTRA',           20.00, 'Para deportistas con buen promedio escolar.',  'ACTIVA'),
(5, 'Beca Talento Juvenil',       'DEPORTIVA',      40.00, 'Convocatoria cerrada.',                        'INACTIVA');


INSERT INTO inscripcion (id_inscripcion, id_estudiante, id_grupo, fecha_inscripcion, fecha_finalizacion, mensualidad_pactada, estado) VALUES
(1, 21, 1, '2026-01-15', NULL,         80000.00,  'ACTIVA'),
(2, 22, 2, '2026-01-15', NULL,         70000.00,  'ACTIVA'),
(3, 23, 4, '2026-02-01', NULL,         120000.00, 'ACTIVA'),
(4, 24, 3, '2026-02-01', NULL,         90000.00,  'ACTIVA'),
(5, 25, 5, '2026-01-20', NULL,         85000.00,  'ACTIVA'),
(6, 26, 7, '2026-03-01', '2026-08-31', 75000.00,  'FINALIZADA'),
(7, 27, 6, '2026-01-15', NULL,         65000.00,  'ACTIVA'),
(8, 21, 2, '2026-01-10', '2026-02-10', 70000.00,  'CANCELADA');


INSERT INTO beca_inscripcion (id_beca_inscripcion, id_inscripcion, id_beca, fecha_inicio, fecha_fin, estado, observaciones) VALUES
(1, 3, 2, '2026-02-01', NULL,         'VIGENTE',    'Estudio socioeconómico aprobado.'),
(2, 5, 1, '2026-01-20', NULL,         'VIGENTE',    'Campeón departamental 2025.'),
(3, 2, 3, '2026-01-15', NULL,         'VIGENTE',    'Hermana inscrita en el club.'),
(4, 1, 3, '2026-01-15', NULL,         'VIGENTE',    'Hermano inscrito en el club.'),
(5, 7, 4, '2026-01-15', '2026-06-30', 'FINALIZADA', 'Terminó el período académico.'),
(6, 6, 1, '2026-03-01', '2026-05-31', 'REVOCADA',   'Dejó de cumplir la condición deportiva.');


_inscripcion, id_beca_inscripcion, periodo_anio, periodo_mes, valor, valor_descuento, fecha_vencimiento, fecha_pago, metodo_pago, estado) VALUES
(1,  1, 4,    2026, 9,  68000.00, 12000.00, '2026-09-05', '2026-09-03', 'TRANSFERENCIA', 'PAGADO'),
(2,  1, 4,    2026, 10, 68000.00, 12000.00, '2026-10-05', NULL,         NULL,            'PENDIENTE'),
(3,  2, 3,    2026, 10, 59500.00, 10500.00, '2026-10-05', '2026-10-02', 'EFECTIVO',      'PAGADO'),
(4,  3, 1,    2026, 10, 84000.00, 36000.00, '2026-10-05', '2026-10-04', 'TARJETA',       'PAGADO'),
(5,  4, NULL, 2026, 10, 90000.00, 0,        '2026-10-05', NULL,         NULL,            'PENDIENTE'),
(6,  5, 2,    2026, 10, 42500.00, 42500.00, '2026-10-05', '2026-10-01', 'TRANSFERENCIA', 'PAGADO'),
(7,  7, NULL, 2026, 10, 65000.00, 0,        '2026-10-05', NULL,         NULL,            'PENDIENTE'),
(8,  4, NULL, 2026, 9,  90000.00, 0,        '2026-09-05', '2026-09-04', 'EFECTIVO',      'PAGADO'),
(9,  6, 6,    2026, 4,  37500.00, 37500.00, '2026-04-05', NULL,         NULL,            'ANULADO'),
(10, 1, 4,    2026, 11, 68000.00, 12000.00, '2026-11-05', NULL,         NULL,            'PENDIENTE');


UPDATE pago
   SET estado = 'VENCIDO'
 WHERE estado = 'PENDIENTE'
   AND fecha_vencimiento < DATE '2026-10-26';


   INSERT INTO entrenamiento (id_entrenamiento, id_grupo, id_entrenador, id_escenario, fecha, hora_inicio, hora_finalizacion, estado, observaciones) VALUES
(1, 1, 1, 1, '2026-10-20', '16:00', '17:30', 'REALIZADO',  NULL),
(2, 1, 1, 1, '2026-10-22', '16:00', '17:30', 'REALIZADO',  NULL),
(3, 2, 2, 3, '2026-10-19', '15:00', '16:30', 'REALIZADO',  NULL),
(4, 3, 3, 3, '2026-10-21', '17:00', '18:30', 'REALIZADO',  NULL),
(5, 4, 4, 4, '2026-10-23', '15:30', '17:00', 'CANCELADO',  'Cancelado por lluvia.'),
(6, 5, 1, 1, '2026-10-20', '18:00', '19:30', 'REALIZADO',  NULL),
(7, 1, 2, 1, '2026-10-27', '16:00', '17:30', 'PROGRAMADO', 'Reemplaza al entrenador principal.');


INSERT INTO asistencia (id_asistencia, id_inscripcion, id_entrenamiento, estado_asistencia, fecha_registro) VALUES
(1, 1, 1, 'ASISTIO',     '2026-10-20 17:35:00'),
(2, 1, 2, 'FALTO',       '2026-10-22 17:35:00'),
(3, 2, 3, 'ASISTIO',     '2026-10-19 16:35:00'),
(4, 4, 4, 'ASISTIO',     '2026-10-21 18:35:00'),
(5, 5, 6, 'JUSTIFICADO', '2026-10-20 19:35:00');


INSERT INTO certificado_medico (id_certificado, id_estudiante, fecha_expedicion, fecha_vencimiento, entidad_emisora, concepto, restricciones, estado) VALUES
(1, 21, '2026-01-10', '2027-01-10', 'IPS Salud Total',      'APTO',                   NULL,                         'VIGENTE'),
(2, 22, '2026-01-10', '2027-01-10', 'IPS Salud Total',      'APTO_CON_RESTRICCIONES', 'Evitar contacto físico fuerte.', 'VIGENTE'),
(3, 23, '2026-01-25', '2027-01-25', 'Clínica Valledupar',   'APTO',                   NULL,                         'VIGENTE'),
(4, 24, '2026-01-25', '2027-01-25', 'Clínica Valledupar',   'APTO',                   NULL,                         'VIGENTE'),
(5, 25, '2025-01-15', '2026-01-15', 'Clínica Valledupar',   'APTO',                   NULL,                         'VIGENTE'),
(6, 25, '2026-01-18', '2027-01-18', 'Clínica Valledupar',   'APTO',                   NULL,                         'VIGENTE'),
(7, 27, '2026-01-12', '2027-01-12', 'IPS Nueva EPS',        'APTO',                   NULL,                         'VIGENTE');


INSERT INTO lesion (id_lesion, id_estudiante, id_entrenamiento, fecha_lesion, tipo_lesion, gravedad, descripcion, fecha_alta, estado) VALUES
(1, 21, 1,    '2026-10-20', 'Esguince de tobillo',  'LEVE',     'Reposo y hielo.',           '2026-10-25', 'RECUPERADO'),
(2, 23, NULL, '2026-09-12', 'Tendinitis de codo',   'MODERADA', 'Fisioterapia dos veces por semana.', NULL, 'EN_TRATAMIENTO'),
(3, 24, 4,    '2026-10-21', 'Contusión de rodilla', 'LEVE',     NULL,                        '2026-10-24', 'RECUPERADO'),
(4, 25, NULL, '2026-05-03', 'Fractura de muñeca',   'GRAVE',    'Inmovilización por 6 semanas.', '2026-06-20', 'RECUPERADO'),
(5, 26, NULL, '2026-04-15', 'Rotura fibrilar',      'MODERADA', 'Rehabilitación guiada.',    '2026-05-30', 'RECUPERADO');


INSERT INTO evaluacion_fisica (id_evaluacion, id_estudiante, id_entrenador, fecha_evaluacion, peso_kg, estatura_cm, frecuencia_reposo, observaciones) VALUES
(1, 21, 1, '2026-03-10', 42.50, 152, 78, 'Buen estado general.'),
(2, 21, 1, '2026-09-10', 45.00, 156, 74, 'Mejora la resistencia.'),
(3, 22, 2, '2026-03-12', 32.00, 138, 80, NULL),
(4, 23, 4, '2026-03-15', 55.50, 166, 70, NULL),
(5, 24, 3, '2026-03-18', 58.00, 168, 68, 'Buena capacidad de salto.'),
(6, 25, 1, '2026-03-20', 68.20, 176, 62, NULL);


INSERT INTO torneo (id_torneo, id_deporte, id_categoria, nombre, tipo_torneo, sede, fecha_inicio, fecha_fin, estado) VALUES
(1, 1, 3, 'Copa Valledupar Sub-12',            'INTERNO',  NULL,                              '2026-09-05', '2026-09-27', 'FINALIZADO'),
(2, 2, 2, 'Torneo de Baloncesto Cesar Sub-10', 'EXTERNO',  'Coliseo Municipal, Valledupar',   '2026-10-10', '2026-11-15', 'EN_CURSO'),
(3, 3, 5, 'Liga Departamental de Voleibol',    'EXTERNO',  'Coliseo de Santa Marta',          '2026-10-15', '2026-11-20', 'EN_CURSO'),
(4, 4, 4, 'Interclubes de Tenis Sub-14',       'AMISTOSO', NULL,                              '2026-12-05', '2026-12-06', 'PROGRAMADO'),
(5, 1, 6, 'Copa Caribe de Fútbol Sub-18',      'EXTERNO',  'Barranquilla',                    '2026-11-07', '2026-11-29', 'PROGRAMADO');


INSERT INTO partido (id_partido, id_torneo, id_grupo, id_escenario, rival, condicion, fecha, hora_inicio, hora_finalizacion, puntos_favor, puntos_contra, estado) VALUES
(1, 1, 1, 1,    'Deportivo Los Cardones', 'LOCAL',     '2026-09-12', '10:00', '11:30', 3,    1,    'JUGADO'),
(2, 1, 1, 1,    'Academia Sabanas FC',    'LOCAL',     '2026-09-19', '10:00', '11:30', 0,    2,    'JUGADO'),
(3, 2, 2, NULL, 'Club Baloncesto Pilonera','VISITANTE','2026-10-17', '14:00', '15:30', 41,   38,   'JUGADO'),
(4, 3, 3, 3,    'Voley Caribe',           'LOCAL',     '2026-10-24', '16:00', '17:30', 3,    2,    'JUGADO'),
(5, 3, 3, NULL, 'Voley Santa Marta',      'VISITANTE', '2026-11-07', '15:00', '16:30', NULL, NULL, 'PROGRAMADO'),
(6, 5, 5, 1,    'Atlético Costa',         'LOCAL',     '2026-11-14', '10:00', '11:30', NULL, NULL, 'APLAZADO');


INSERT INTO convocatoria (id_convocatoria, id_partido, id_inscripcion, es_titular, minutos_jugados, observaciones) VALUES
(1, 1, 1, TRUE,  60,   'Anotó un gol.'),
(2, 2, 1, TRUE,  55,   NULL),
(3, 3, 2, TRUE,  30,   NULL),
(4, 4, 4, TRUE,  100,  NULL),
(5, 5, 4, FALSE, NULL, 'Convocada para el próximo partido.'),
(6, 6, 5, FALSE, NULL, 'Partido aplazado.');
