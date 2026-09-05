# Esquema Relacional — Sistema de Gestión Deportiva

## 1. Persona

**PERSONA**
( `id_Persona` **PK**, `num_documento`, `nombres`, `fecha_nacimiento`, `genero`, `rh`, `telefono`, `apellidos`, `eps`, `direccion` )

--------------------------------------------------------------------------------------------------------------------------------------------

## 2. Entrenador

**ENTRENADOR**
( `id_Entrenador` **PK/FK → PERSONA(`id_Persona`)**, `salario`, `fecha_ingreso` )

**Clave foránea:**

* `id_Entrenador` → PERSONA(`id_Persona`)

**Política de borrado:** **RESTRINGIR**

**Por qué:** no se debe eliminar una persona que tenga una especialización como entrenador sin revisar primero dicha relación.

--------------------------------------------------------------------------------------------------------------------------------------------

## 3. Estudiante

**ESTUDIANTE**
( `id_Estudiante` **PK/FK → PERSONA(`id_Persona`)**, `id_acudiente` **FK → ACUDIENTE(`id_Acudiente`)**, `mensualidad` )

**Claves foráneas:**

* `id_Estudiante` → PERSONA(`id_Persona`)
* `id_acudiente` → ACUDIENTE(`id_Acudiente`)

**Política de borrado de `id_Estudiante`:** **RESTRINGIR**

**Por qué:** un estudiante puede tener inscripciones asociadas, por lo que no debe eliminarse directamente sin revisar sus registros relacionados.

**Política de borrado de `id_acudiente`:** **RESTRINGIR**

**Por qué:** un acudiente puede estar asociado a uno o varios estudiantes, por lo que no debe eliminarse mientras existan estudiantes relacionados.

--------------------------------------------------------------------------------------------------------------------------------------------

## 4. Acudiente

**ACUDIENTE**
( `id_Acudiente` **PK/FK → PERSONA(`id_Persona`)**, `parentesco` )

**Clave foránea:**

* `id_Acudiente` → PERSONA(`id_Persona`)

**Política de borrado:** **RESTRINGIR**

**Por qué:** se conserva la información de la persona y su especialización como acudiente para evitar pérdida accidental de información.

--------------------------------------------------------------------------------------------------------------------------------------------

## 5. Deporte

**DEPORTE**
( `id_Deporte` **PK**, `nombre` )

--------------------------------------------------------------------------------------------------------------------------------------------

## 6. Categoría

**CATEGORIA**
( `id_Categoria` **PK**, `id_Deporte` **FK → DEPORTE(`id_Deporte`)**, `nombre`, `rango_edad` )

**Clave foránea:**

* `id_Deporte` → DEPORTE(`id_Deporte`)

**Política de borrado de `id_Deporte`:** **RESTRINGIR**

**Por qué:** no se debe eliminar un deporte si todavía tiene categorías asociadas.

--------------------------------------------------------------------------------------------------------------------------------------------

## 7. Inscripción

**INSCRIPCION**
( `id_Inscripcion` **PK**, `id_Estudiante` **FK → ESTUDIANTE(`id_Estudiante`)**, `id_Categoria` **FK → CATEGORIA(`id_Categoria`)**, `fecha_inscripcion`, `fecha_finalizacion`, `estado` )

**Claves foráneas:**

* `id_Estudiante` → ESTUDIANTE(`id_Estudiante`)
* `id_Categoria` → CATEGORIA(`id_Categoria`)

**Política de borrado de `id_Estudiante`:** **RESTRINGIR**

**Por qué:** un estudiante puede tener varias inscripciones y eliminarlo podría dejar información académica/deportiva inconsistente.

**Política de borrado de `id_Categoria`:** **RESTRINGIR**

**Por qué:** una categoría no debe eliminarse mientras existan estudiantes inscritos en ella.

--------------------------------------------------------------------------------------------------------------------------------------------

## 8. Pago

**PAGO**
( `id_Pago` **PK**, `id_Inscripcion` **FK → INSCRIPCION(`id_Inscripcion`)**, `fecha_pago`, `valor`, `metodo_pago`, `estado` )

**Clave foránea:**

* `id_Inscripcion` → INSCRIPCION(`id_Inscripcion`)

**Política de borrado de `id_Inscripcion`:** **CASCADE**

**Por qué:** los pagos dependen directamente de una inscripción. Si una inscripción se elimina, sus pagos asociados deben eliminarse para evitar registros huérfanos.

--------------------------------------------------------------------------------------------------------------------------------------------

## 9. Escenario

**ESCENARIO**
( `id_Escenario` **PK**, `nombre`, `tipo_Escenario`, `Ubicacion` )

--------------------------------------------------------------------------------------------------------------------------------------------

## 10. Entrenamiento

**ENTRENAMIENTO**
( `id_Entrenamiento` **PK**, `id_Entrenador` **FK → ENTRENADOR(`id_Entrenador`)**, `id_Escenario` **FK → ESCENARIO(`id_Escenario`)**, `fecha`, `hora_inicio`, `hora_finalizacion`, `estado` )

**Claves foráneas:**

* `id_Entrenador` → ENTRENADOR(`id_Entrenador`)
* `id_Escenario` → ESCENARIO(`id_Escenario`)

**Política de borrado de `id_Entrenador`:** **RESTRINGIR**

**Por qué:** no se debe eliminar un entrenador si tiene entrenamientos registrados, ya que se perdería la referencia histórica de quién los realizó.

**Política de borrado de `id_Escenario`:** **RESTRINGIR**

**Por qué:** no se debe eliminar un escenario mientras tenga entrenamientos asociados, para conservar la información histórica de dónde se realizaron.

--------------------------------------------------------------------------------------------------------------------------------------------

## 11. Asistencia

**ASISTENCIA**
( `id_Asistencia` **PK**, `id_Inscripcion` **FK → INSCRIPCION(`id_Inscripcion`)**, `id_Entrenamiento` **FK → ENTRENAMIENTO(`id_Entrenamiento`)**, `fecha_registro`, `estado_asistencia` )

**Claves foráneas:**

* `id_Inscripcion` → INSCRIPCION(`id_Inscripcion`)
* `id_Entrenamiento` → ENTRENAMIENTO(`id_Entrenamiento`)

**Política de borrado de `id_Inscripcion`:** **CASCADE**

**Por qué:** la asistencia depende de una inscripción específica. Si la inscripción se elimina, sus registros de asistencia dejan de tener sentido.

**Política de borrado de `id_Entrenamiento`:** **CASCADE**

**Por qué:** los registros de asistencia dependen del entrenamiento al que pertenecen. Al eliminar el entrenamiento, sus asistencias asociadas deben eliminarse para evitar registros huérfanos.

--------------------------------------------------------------------------------------------------------------------------------------------

# Resumen de claves foráneas

| Tabla             | Clave foránea      | Referencia                        | Política de borrado |
| ----------------- | ------------------ | --------------------------------- | ------------------- |
| **ENTRENADOR**    | `id_Entrenador`    | PERSONA(`id_Persona`)             | **RESTRINGIR**      |
| **ESTUDIANTE**    | `id_Estudiante`    | PERSONA(`id_Persona`)             | **RESTRINGIR**      |
| **ESTUDIANTE**    | `id_acudiente`     | ACUDIENTE(`id_Acudiente`)         | **RESTRINGIR**      |
| **ACUDIENTE**     | `id_Acudiente`     | PERSONA(`id_Persona`)             | **RESTRINGIR**      |
| **CATEGORIA**     | `id_Deporte`       | DEPORTE(`id_Deporte`)             | **RESTRINGIR**      |
| **INSCRIPCION**   | `id_Estudiante`    | ESTUDIANTE(`id_Estudiante`)       | **RESTRINGIR**      |
| **INSCRIPCION**   | `id_Categoria`     | CATEGORIA(`id_Categoria`)         | **RESTRINGIR**      |
| **PAGO**          | `id_Inscripcion`   | INSCRIPCION(`id_Inscripcion`)     | **CASCADE**         |
| **ENTRENAMIENTO** | `id_Entrenador`    | ENTRENADOR(`id_Entrenador`)       | **RESTRINGIR**      |
| **ENTRENAMIENTO** | `id_Escenario`     | ESCENARIO(`id_Escenario`)         | **RESTRINGIR**      |
| **ASISTENCIA**    | `id_Inscripcion`   | INSCRIPCION(`id_Inscripcion`)     | **CASCADE**         |
| **ASISTENCIA**    | `id_Entrenamiento` | ENTRENAMIENTO(`id_Entrenamiento`) | **CASCADE**         |

# Relaciones principales

* **PERSONA → ENTRENADOR:** una persona puede corresponder a un entrenador.
* **PERSONA → ESTUDIANTE:** una persona puede corresponder a un estudiante.
* **PERSONA → ACUDIENTE:** una persona puede corresponder a un acudiente.
* **ACUDIENTE → ESTUDIANTE:** un acudiente puede estar asociado a uno o varios estudiantes.
* **DEPORTE → CATEGORIA:** un deporte puede tener varias categorías.
* **ESTUDIANTE → INSCRIPCION:** un estudiante puede tener varias inscripciones.
* **CATEGORIA → INSCRIPCION:** una categoría puede tener varias inscripciones.
* **INSCRIPCION → PAGO:** una inscripción puede registrar varios pagos.
* **ENTRENADOR → ENTRENAMIENTO:** un entrenador puede realizar varios entrenamientos.
* **ESCENARIO → ENTRENAMIENTO:** un escenario puede utilizarse en varios entrenamientos.
* **INSCRIPCION → ASISTENCIA:** una inscripción puede tener varios registros de asistencia.
* **ENTRENAMIENTO → ASISTENCIA:** un entrenamiento puede tener varios registros de asistencia.
