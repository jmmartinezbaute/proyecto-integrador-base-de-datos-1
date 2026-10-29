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