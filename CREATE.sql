/* ======= DATOS PREVIOS ======= */
CREATE TABLE dbo.Pais (
    id_pais INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    moneda NVARCHAR(10) NOT NULL,
    prefijo NVARCHAR(10) NOT NULL,
    codigo_ISO NVARCHAR(5) UNIQUE NOT NULL,
    -- VALIDACIONES
    CONSTRAINT CHK_Pais_CodigoISO CHECK (LEN(codigo_ISO) >= 2 AND codigo_ISO = UPPER(codigo_ISO)), -- ISO debe ser mayúsculas y mínimo 2 caracteres
    CONSTRAINT CHK_Pais_Prefijo CHECK (prefijo LIKE '+%') -- Prefijo debe empezar con +
);

CREATE TABLE dbo.Ciudad (
    id_ciudad INT IDENTITY(1,1) PRIMARY KEY,
    id_pais INT NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    codigo_postal NVARCHAR(10),
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    id_usuario_crea INT NULL,
    id_usuario_modifica INT NULL,
    CONSTRAINT FK_Ciudad_Pais FOREIGN KEY (id_pais) REFERENCES Pais(id_pais),
    -- VALIDACIONES
    CONSTRAINT CHK_Ciudad_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion) -- Fecha modificación debe ser mayor a creación
);

GO
CREATE TABLE dbo.Idioma (
    id_idioma INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    codigo_iso NVARCHAR(10) NULL,
    -- VALIDACIONES
    CONSTRAINT CHK_Idioma_CodigoISO CHECK (codigo_iso IS NULL OR (LEN(codigo_iso) >= 2 AND codigo_iso = LOWER(codigo_iso))) -- CAMBIO: Código ISO en minúsculas (estándar)
);

GO
CREATE TABLE dbo.Tipo_Tour (
    id_tipo_tour INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(150) NOT NULL,
    descripcion NVARCHAR(300) NULL,
    duracion_estimada NVARCHAR(50),
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    id_usuario_crea INT NULL,
    id_usuario_modifica INT NULL,
    -- VALIDACIONES
    CONSTRAINT CHK_TipoTour_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion) -- CAMBIO: Validación de fechas
);

GO
CREATE TABLE dbo.Sitio_Turistico(
    id_sitio_turistico INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(200) NOT NULL,
    valor_entrada DECIMAL(10,2) NULL,
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    id_usuario_crea INT NULL,
    id_usuario_modifica INT NULL,
    -- VALIDACIONES
    CONSTRAINT CHK_Sitio_ValorEntrada CHECK (valor_entrada IS NULL OR valor_entrada >= 0), -- Valor no puede ser negativo
    CONSTRAINT CHK_Sitio_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion) -- Validación de fechas
);

GO
/* ======= MULTIMEDIA ======= */
CREATE TABLE dbo.Multimedia (
    id_multimedia INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(250) NULL,
    extension NVARCHAR(10) NULL,
    url NVARCHAR(500) NULL,
    activo BIT NOT NULL DEFAULT 1,
    fecha_subida DATETIME NOT NULL DEFAULT GETDATE(),
    id_usuario_sube INT NULL,
    -- VALIDACIONES
    CONSTRAINT CHK_Multimedia_Extension CHECK (
        extension IS NULL OR 
        extension IN ('.jpg', '.jpeg', '.png', '.gif', '.webp', '.mp4', '.mov', '.avi', '.pdf')
    ), -- Solo extensiones permitidas
);

GO
/* ======= USUARIOS ======= */
CREATE TABLE dbo.Usuario (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NULL,
    correo NVARCHAR(250) NULL UNIQUE,
    tipo_documento NVARCHAR(5) NOT NULL,
    documento_identidad NVARCHAR(50) NULL UNIQUE,
    telefono NVARCHAR(30) NULL,
    ciudad_residencia INT NOT NULL,
    ciudad_nacimiento INT NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    CONSTRAINT FK_Ciudad_Res_Pais FOREIGN KEY (ciudad_residencia) REFERENCES Ciudad(id_ciudad),
    CONSTRAINT FK_Ciudad_Nac_Pais FOREIGN KEY (ciudad_nacimiento) REFERENCES Ciudad(id_ciudad),
    -- VALIDACIONES
    CONSTRAINT CHK_Usuario_Correo CHECK (correo IS NULL OR correo LIKE '%_@__%.__%'), -- Formato básico de email
    CONSTRAINT CHK_Usuario_FechaNacimiento CHECK (fecha_nacimiento < CAST(GETDATE() AS DATE)), -- No puede nacer en el futuro xd
    CONSTRAINT CHK_Usuario_EdadMinima CHECK (DATEDIFF(YEAR, fecha_nacimiento, GETDATE()) >= 18), -- Edad mínima 18 años
    --CONSTRAINT CHK_Usuario_TipoDocumento CHECK (tipo_documento IN ('CC', 'CE', 'PA', 'TI', 'NIT')), -- Tipos de documento válidos
    CONSTRAINT CHK_Usuario_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion) -- Validación de fechas
);

GO
/* ======= ADMINISTRADOR ======= */
CREATE TABLE dbo.Administrador (
    id_administrador INT PRIMARY KEY,
    rol VARCHAR(50) NOT NULL,
    email_alternativo NVARCHAR(250) NULL,
    telefono_emergencia NVARCHAR(30) NULL,
    verificaciones_realizadas INT DEFAULT 0,
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Administrador_Usuarios FOREIGN KEY (id_administrador) REFERENCES dbo.Usuario(id_usuario),
    CONSTRAINT CHK_Administrador_Rol CHECK (
        rol IN ('Superadmin', 'Marketing', 'Soporte', 'Verificador')
    ),
    -- VALIDACIONES
    CONSTRAINT CHK_Administrador_EmailAlt CHECK (email_alternativo IS NULL OR email_alternativo LIKE '%_@__%.__%'), -- Formato email
    CONSTRAINT CHK_Administrador_Verificaciones CHECK (verificaciones_realizadas >= 0) -- No puede ser negativo
);

CREATE TABLE dbo.Centro_Educativo (
    id_centro INT IDENTITY(1,1) PRIMARY KEY,
    id_ciudad INT NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    tituloObtenido NVARCHAR(100) NOT NULL,
    codigo NVARCHAR(10) NULL,
    numero_tarjeta_profesional INT NULL,
    fecha_ingreso DATE NOT NULL,
    fecha_egreso DATE NULL,
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    id_admin_crea INT NOT NULL,
    CONSTRAINT FK_Centro_Ciudad FOREIGN KEY (id_ciudad) REFERENCES Ciudad(id_ciudad),
    CONSTRAINT FK_Centro_Administrador FOREIGN KEY (id_admin_crea) REFERENCES Administrador(id_administrador),
    -- VALIDACIONES
    CONSTRAINT CHK_Centro_FechaEgreso CHECK (fecha_egreso IS NULL OR fecha_egreso > fecha_ingreso), -- Egreso después de ingreso
    CONSTRAINT CHK_Centro_FechaIngreso CHECK (fecha_ingreso >= '1950-01-01'), -- Fecha realista
    CONSTRAINT CHK_Centro_TarjetaProfesional CHECK (numero_tarjeta_profesional IS NULL OR numero_tarjeta_profesional > 0) -- Número positivo
);

GO
/* ======= TURISTAS ======= */
CREATE TABLE dbo.Turista (
    id_turista INT PRIMARY KEY,
    tours_completados INT DEFAULT 0,
    tipo_viajero VARCHAR(50) NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Turista_Usuario FOREIGN KEY (id_turista) REFERENCES dbo.Usuario(id_usuario),
    CONSTRAINT CHK_Turista_TipoViajero CHECK (
        tipo_viajero IN ('solo', 'pareja', 'familia', 'grupo', 'negocios')
    ),
    -- VALIDACIONES
    CONSTRAINT CHK_Turista_ToursCompletados CHECK (tours_completados >= 0) -- No puede ser negativo
);

GO
CREATE TABLE dbo.Turista_Idioma (
    id_turista INT NOT NULL,
    id_idioma INT NOT NULL,
    PRIMARY KEY (id_turista, id_idioma),
    CONSTRAINT FK_TuristaIdioma_Turista FOREIGN KEY (id_turista) REFERENCES dbo.Turista(id_turista),
    CONSTRAINT FK_TuristaIdioma_Idioma FOREIGN KEY (id_idioma) REFERENCES dbo.Idioma(id_idioma)
);

CREATE TABLE dbo.Turista_Interes (
    id_interes INT IDENTITY PRIMARY KEY,
    id_turista INT,
    id_tipo_tour INT,
    nivel_interes NVARCHAR(20),
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    CONSTRAINT FK_Turista_Interes FOREIGN KEY (id_turista) REFERENCES Turista(id_turista),
    CONSTRAINT FK_Turista_Tour FOREIGN KEY (id_tipo_tour) REFERENCES Tipo_Tour(id_tipo_tour),
    CONSTRAINT CHK_Turista_interes CHECK (
        nivel_interes IN ('Bajo', 'Medio', 'Alto', 'Muy Interesado')
    ),
    -- VALIDACIONES
    CONSTRAINT CHK_TuristaInteres_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion) -- Validación de fechas
);

CREATE TABLE dbo.Notificacion (
    id_notificacion INT IDENTITY(1,1) PRIMARY KEY,
    id_destinatario INT NOT NULL,
    tipo NVARCHAR(100) NULL,
    titulo NVARCHAR(1000) NULL,
    mensaje NVARCHAR(1000) NULL,
    fecha_envio DATETIME NULL,
    medio NVARCHAR(50) NULL,
    estado NVARCHAR(20) NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    id_usuario_crea INT NULL,
    CONSTRAINT CHK_Notificacion_Estado CHECK (
        estado IN ('Enviado', 'Recibido', 'Leido')
    ),
    -- VALIDACIONES
    CONSTRAINT CHK_Notificacion_Medio CHECK (
        medio IS NULL OR medio IN ('Email', 'SMS', 'Push', 'WhatsApp')
    ), -- Medios permitidos
    CONSTRAINT CHK_Notificacion_FechaEnvio CHECK (fecha_envio IS NULL OR fecha_envio >= fecha_creacion) -- Envío después de creación
);

CREATE TABLE dbo.Contactos_Emergencia (
    id_contacto INT IDENTITY(1,1) PRIMARY KEY,
    id_turista INT NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NOT NULL,
    correo NVARCHAR(250) NULL,
    parentesco NVARCHAR(50) NULL,
    telefono NVARCHAR(30) NOT NULL,
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    CONSTRAINT FK_Contactos_Turista FOREIGN KEY (id_turista) REFERENCES dbo.Turista(id_turista),
    -- VALIDACIONES
    CONSTRAINT CHK_Contacto_Correo CHECK (correo IS NULL OR correo LIKE '%_@__%.__%'), -- Formato email
    CONSTRAINT CHK_Contacto_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion) -- Validación de fechas
);

CREATE TABLE dbo.Recomendacion(
    id_recomendacion INT IDENTITY(1,1) PRIMARY KEY,
    titulo NVARCHAR(100) NOT NULL,
    detalle NVARCHAR(1000) NOT NULL,
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    id_usuario_crea INT NULL,
    -- VALIDACIONES
    CONSTRAINT CHK_Recomendacion_Titulo CHECK (LEN(TRIM(titulo)) >= 5), -- Título mínimo 5 caracteres
);

CREATE TABLE dbo.Recomendacion_Turista(
    id_recomendacion_turista INT IDENTITY(1,1) PRIMARY KEY,
    id_recomendacion INT NOT NULL,
    id_turista INT NOT NULL,
    fecha_envio DATETIME NOT NULL DEFAULT GETDATE(),
    aceptada BIT NOT NULL DEFAULT 0,
    fecha_aceptacion DATETIME NULL,
    CONSTRAINT FK_Recomendacion_Turista_id FOREIGN KEY (id_turista) REFERENCES dbo.Turista(id_turista),
    CONSTRAINT FK_Recomendacion_Recomendacion_id FOREIGN KEY (id_recomendacion) REFERENCES dbo.Recomendacion(id_recomendacion),
    -- VALIDACIONES
    CONSTRAINT CHK_RecomendacionTurista_FechaAceptacion CHECK (fecha_aceptacion IS NULL OR fecha_aceptacion >= fecha_envio), --  Aceptación después de envío
    CONSTRAINT CHK_RecomendacionTurista_Logica CHECK (
        (aceptada = 0 AND fecha_aceptacion IS NULL) OR 
        (aceptada = 1 AND fecha_aceptacion IS NOT NULL)
    ) -- CAMBIO: Si está aceptada debe tener fecha
);

GO
/* ======= GUIAS ======= */
CREATE TABLE dbo.Estado_Guia (
    id_estado INT IDENTITY PRIMARY KEY,
    nombre NVARCHAR(50) UNIQUE NOT NULL,
    descripcion NVARCHAR(200),
    CONSTRAINT CHK_Estado_Guia_Nombre CHECK (
        nombre IN ('Pendiente', 'Verificado', 'Inactivo', 'Suspendido', 'Reactivado')
    )
);

CREATE TABLE dbo.Verificacion_Guia (
    id_verificacion INT IDENTITY PRIMARY KEY,
    id_guia INT NOT NULL,
    id_administrador INT NOT NULL,
    id_estado_resultado INT NOT NULL,
    fecha_verificacion DATETIME NOT NULL DEFAULT GETDATE(),
    observacion NVARCHAR(500),
    CONSTRAINT FK_Verificacion_Administrador FOREIGN KEY (id_administrador) REFERENCES dbo.Administrador(id_administrador),
    CONSTRAINT FK_Verificacion_Estado FOREIGN KEY (id_estado_resultado) REFERENCES dbo.Estado_Guia(id_estado),
    -- VALIDACIONES
    CONSTRAINT CHK_Verificacion_Observacion CHECK (
        observacion IS NULL OR LEN(TRIM(observacion)) >= 10
    ) -- Observación mínimo 10 caracteres si existe
);

CREATE TABLE dbo.Guia (
    id_guia INT PRIMARY KEY,
    biografia NVARCHAR(1000) NULL,
    foto_perfil NVARCHAR(500) NULL,
    id_estado_actual INT NOT NULL,
    calificacion_promedio DECIMAL(3,2) NULL CHECK (calificacion_promedio BETWEEN 0 AND 5), 
    total_resenas INT NOT NULL DEFAULT 0,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    CONSTRAINT FK_Guia_Usuario FOREIGN KEY (id_guia) REFERENCES dbo.Usuario(id_usuario),
    CONSTRAINT FK_Guia_Estado FOREIGN KEY (id_estado_actual) REFERENCES dbo.Estado_Guia(id_estado),
    -- VALIDACIONES
    CONSTRAINT CHK_Guia_TotalResenas CHECK (total_resenas >= 0), -- No puede ser negativo
    CONSTRAINT CHK_Guia_Biografia CHECK (biografia IS NULL OR LEN(TRIM(biografia)) >= 50), -- Biografía mínimo 50 caracteres
    CONSTRAINT CHK_Guia_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion) -- CAMBIO: Validación de fechas
);

ALTER TABLE dbo.Verificacion_Guia 
ADD CONSTRAINT FK_Verificacion_Guia FOREIGN KEY (id_guia) REFERENCES dbo.Guia(id_guia);

GO
CREATE TABLE dbo.Guia_Idioma (
    id_guia INT NOT NULL,
    id_idioma INT NOT NULL,
    nivel NVARCHAR(50) NULL,
    PRIMARY KEY (id_guia, id_idioma),
    CONSTRAINT FK_GuiaIdioma_Guia FOREIGN KEY (id_guia) REFERENCES dbo.Guia(id_guia),
    CONSTRAINT FK_GuiaIdioma_Idioma FOREIGN KEY (id_idioma) REFERENCES dbo.Idioma(id_idioma),
    CONSTRAINT CHK_GuiaIdioma_Nivel CHECK (
        nivel IN ('BÁSICO', 'INTERMEDIO', 'AVANZADO', 'NATIVO')
    )
);

GO
CREATE TABLE Experiencia_Guia (
    id_experiencia INT IDENTITY(1,1) PRIMARY KEY,
    id_guia INT NOT NULL,
    lugar NVARCHAR(100),
    cargo NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(200),
    fecha_inicio DATE NOT NULL,
    fecha_terminacion DATE,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    FOREIGN KEY (id_guia) REFERENCES Guia(id_guia),
    -- VALIDACIONES
    CONSTRAINT CHK_Experiencia_FechaTerminacion CHECK (fecha_terminacion IS NULL OR fecha_terminacion > fecha_inicio), -- Terminación después de inicio
    CONSTRAINT CHK_Experiencia_FechaInicio CHECK (fecha_inicio >= '1950-01-01' AND fecha_inicio <= CAST(GETDATE() AS DATE)), -- Fecha realista
    CONSTRAINT CHK_Experiencia_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion) -- Validación de fechas
);

GO
CREATE TABLE Profesion (
    id_profesion INT IDENTITY(1,1) PRIMARY KEY,
    id_centro_educativo INT NOT NULL,
    nombre NVARCHAR(100),
    activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Centro_Profesion FOREIGN KEY (id_centro_educativo) REFERENCES dbo.Centro_Educativo(id_centro),
    -- VALIDACIONES
    CONSTRAINT CHK_Profesion_Nombre CHECK (LEN(TRIM(nombre)) >= 3) -- Nombre mínimo 3 caracteres
);

GO
CREATE TABLE Profesion_Guia (  
    id_profesion_guia INT IDENTITY PRIMARY KEY,
    id_guia INT NOT NULL,
    id_profesion INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_terminacion DATE,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (id_guia) REFERENCES Guia(id_guia),
    FOREIGN KEY (id_profesion) REFERENCES Profesion(id_profesion),
    -- VALIDACIONES
    CONSTRAINT CHK_ProfesionGuia_FechaTerminacion CHECK (fecha_terminacion IS NULL OR fecha_terminacion > fecha_inicio), 
    CONSTRAINT CHK_ProfesionGuia_FechaInicio CHECK (fecha_inicio >= '1950-01-01' AND fecha_inicio <= CAST(GETDATE() AS DATE)) 
);

GO
/* ======= TOUR ======= */
CREATE TABLE dbo.Punto_Encuentro (
    id_punto_encuentro INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(200) NOT NULL,
    direccion NVARCHAR(300) NULL,
    referencia NVARCHAR(300) NULL,
    id_ciudad INT NOT NULL,
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    id_usuario_crea INT NULL,
    id_usuario_modifica INT NULL,
    CONSTRAINT FK_PuntoEncuentro_Ciudad FOREIGN KEY (id_ciudad) REFERENCES dbo.Ciudad(id_ciudad),
    -- VALIDACIONES
    CONSTRAINT CHK_PuntoEncuentro_Nombre CHECK (LEN(TRIM(nombre)) >= 3), 
    CONSTRAINT CHK_PuntoEncuentro_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion)
);

GO
CREATE TABLE dbo.Tour (
    id_tour INT IDENTITY(1,1) PRIMARY KEY,
    id_guia INT NOT NULL,
    nombre NVARCHAR(200) NOT NULL,
    descripcion NVARCHAR(MAX) NULL,
    duracion_estimada DECIMAL(4,2) NULL,
    id_ciudad INT NULL,
    id_tipo_tour INT NULL,
    activo BIT NOT NULL DEFAULT 1, 
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    id_usuario_modifica INT NULL,
    CONSTRAINT FK_Tour_Guia FOREIGN KEY (id_guia) REFERENCES dbo.Guia(id_guia),
    CONSTRAINT FK_Tour_Ciudad FOREIGN KEY (id_ciudad) REFERENCES dbo.Ciudad(id_ciudad),
    CONSTRAINT FK_Tour_TipoTour FOREIGN KEY (id_tipo_tour) REFERENCES dbo.Tipo_Tour(id_tipo_tour),
    -- VALIDACIONES
    CONSTRAINT CHK_Tour_Nombre CHECK (LEN(TRIM(nombre)) >= 5), -- Nombre mínimo 5 caracteres
    CONSTRAINT CHK_Tour_Descripcion CHECK (descripcion IS NULL OR LEN(TRIM(descripcion)) >= 20), -- 
    CONSTRAINT CHK_Tour_Duracion CHECK (duracion_estimada IS NULL OR duracion_estimada BETWEEN 0.5 AND 72),
    CONSTRAINT CHK_Tour_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion)
);

GO
CREATE TABLE dbo.Tour_Idioma (
    id_tour_idioma INT IDENTITY(1,1) PRIMARY KEY,
    id_tour INT NOT NULL,
    id_idioma INT NOT NULL,
    CONSTRAINT FK_TourIdioma_Tour FOREIGN KEY (id_tour) REFERENCES dbo.Tour(id_tour),
    CONSTRAINT FK_TourIdioma_Idioma FOREIGN KEY (id_idioma) REFERENCES dbo.Idioma(id_idioma),
    CONSTRAINT UQ_Tour_Idioma UNIQUE (id_tour, id_idioma)
);

GO
CREATE TABLE dbo.Tour_Recorrido(
    id_tour_sitio INT IDENTITY(1,1) PRIMARY KEY,
    id_tour INT NOT NULL,
    id_sitio INT NOT NULL,
    orden INT NULL,
    CONSTRAINT FK_Tour_Sitio FOREIGN KEY (id_tour) REFERENCES dbo.Tour(id_tour),
    CONSTRAINT FK_Sitio_Turistico FOREIGN KEY (id_sitio) REFERENCES dbo.Sitio_Turistico(id_sitio_turistico),
    CONSTRAINT UQ_Tour_Sitio UNIQUE (id_tour, id_sitio),
    -- VALIDACIONES
    CONSTRAINT CHK_TourRecorrido_Orden CHECK (orden IS NULL OR orden > 0) 
);

GO
CREATE TABLE dbo.Estado_Tour_Salida (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(200)
);

CREATE TABLE dbo.Estado_Reserva (
    id_estado INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion VARCHAR(200)
);

GO
CREATE TABLE dbo.Tour_Salida (
    id_salida INT IDENTITY(1,1) PRIMARY KEY,
    id_tour INT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NULL,
    cupos_maximos INT NOT NULL,
    cupos_disponibles INT NOT NULL,
    id_punto_encuentro INT NULL,
    id_estado_salida INT NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    id_usuario_crea INT NOT NULL,
    id_usuario_modifica INT NULL,
    CONSTRAINT FK_Salida_Tour FOREIGN KEY (id_tour) REFERENCES dbo.Tour(id_tour),
    CONSTRAINT FK_Salida_PuntoEncuentro FOREIGN KEY (id_punto_encuentro) REFERENCES dbo.Punto_Encuentro(id_punto_encuentro), 
    CONSTRAINT FK_Salida_Estado FOREIGN KEY (id_estado_salida) REFERENCES dbo.Estado_Tour_Salida(id_estado), 
    CONSTRAINT CHK_Salida_Cupos CHECK (cupos_disponibles <= cupos_maximos),
    -- VALIDACIONES
    CONSTRAINT CHK_Salida_CuposDisponibles CHECK (cupos_disponibles >= 0), 
    CONSTRAINT CHK_Salida_HoraFin CHECK (hora_fin IS NULL OR hora_fin > hora_inicio), 
    CONSTRAINT CHK_Salida_Fecha CHECK (fecha >= CAST(GETDATE() AS DATE)), 
    CONSTRAINT CHK_Salida_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion) 
);

GO
CREATE TABLE dbo.Tour_Multimedia (
    id_tour_multimedia INT IDENTITY(1,1) PRIMARY KEY,
    id_tour INT NOT NULL,
    id_multimedia INT NOT NULL,
    descripcion NVARCHAR(300) NULL,
    es_principal BIT NOT NULL DEFAULT 0,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_TourMultimedia_Tour FOREIGN KEY (id_tour) REFERENCES dbo.Tour(id_tour),
    CONSTRAINT FK_TourMultimedia_Multimedia FOREIGN KEY (id_multimedia) REFERENCES dbo.Multimedia(id_multimedia),
    CONSTRAINT UQ_Tour_Multimedia UNIQUE (id_tour, id_multimedia)
);

GO
/* ======= RESERVAS ======= */
CREATE TABLE dbo.Reserva (
    id_reserva INT IDENTITY(1,1) PRIMARY KEY,
    codigo_reserva NVARCHAR(50) NOT NULL UNIQUE,
    id_turista INT NOT NULL,
    numero_personas INT NOT NULL CHECK (numero_personas >= 1),
    fecha_reserva DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    id_usuario_modifica INT NULL,
    CONSTRAINT FK_Reserva_Turista FOREIGN KEY (id_turista) REFERENCES dbo.Turista(id_turista),
    -- VALIDACIONES
    CONSTRAINT CHK_Reserva_NumeroPersonas CHECK (numero_personas BETWEEN 1 AND 50), 
    CONSTRAINT CHK_Reserva_CodigoReserva CHECK (LEN(codigo_reserva) >= 6),
    CONSTRAINT CHK_Reserva_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_reserva) 
);

GO
CREATE TABLE dbo.Reserva_Salida (
    id_reserva INT NOT NULL,
    id_salida INT NOT NULL,
    id_estado_reserva INT NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_modificacion DATETIME NULL,
    PRIMARY KEY (id_reserva, id_salida),
    CONSTRAINT FK_ReservaSalida_Reserva FOREIGN KEY (id_reserva) REFERENCES dbo.Reserva(id_reserva),
    CONSTRAINT FK_ReservaSalida_Salida FOREIGN KEY (id_salida) REFERENCES dbo.Tour_Salida(id_salida),
    CONSTRAINT FK_Reserva_Estado FOREIGN KEY (id_estado_reserva) REFERENCES dbo.Estado_Reserva(id_estado),
    -- VALIDACIONES
    CONSTRAINT CHK_ReservaSalida_FechaModificacion CHECK (fecha_modificacion IS NULL OR fecha_modificacion >= fecha_creacion) 
);

GO
CREATE TABLE dbo.Historial_Reserva_Salida (
    id_historial INT IDENTITY(1,1) PRIMARY KEY,
    id_reserva INT NOT NULL,
    id_salida INT NOT NULL,
    fecha_cambio DATETIME NOT NULL DEFAULT GETDATE(),
    id_estado_anterior INT NULL,
    id_estado_nuevo INT NOT NULL,
    id_usuario INT NULL,
    comentario NVARCHAR(500) NULL,
    CONSTRAINT FK_HistorialReservaSalida_ReservaSalida 
        FOREIGN KEY (id_reserva, id_salida) 
        REFERENCES dbo.Reserva_Salida(id_reserva, id_salida),
    CONSTRAINT FK_HistorialReservaSalida_EstadoAnterior
        FOREIGN KEY (id_estado_anterior) 
        REFERENCES dbo.Estado_Reserva(id_estado),
    CONSTRAINT FK_HistorialReservaSalida_EstadoNuevo
        FOREIGN KEY (id_estado_nuevo) 
        REFERENCES dbo.Estado_Reserva(id_estado),
    -- VALIDACIONES
    CONSTRAINT CHK_Historial_EstadosDiferentes CHECK (id_estado_anterior IS NULL OR id_estado_anterior != id_estado_nuevo), 
    CONSTRAINT CHK_Historial_Comentario CHECK (comentario IS NULL OR LEN(TRIM(comentario)) >= 5) 
);

GO
CREATE TABLE dbo.Reseña (
    id_reseña INT IDENTITY(1,1) PRIMARY KEY, 
    id_reserva INT NOT NULL,
    id_salida INT NOT NULL,
    id_turista INT NOT NULL,
    id_tour INT NOT NULL,
    id_guia INT NOT NULL,
    calificacion_tour TINYINT NOT NULL CHECK (calificacion_tour BETWEEN 1 AND 5),
    calificacion_guia TINYINT NOT NULL CHECK (calificacion_guia BETWEEN 1 AND 5),
    comentario NVARCHAR(2000) NULL,
    verificada BIT NOT NULL DEFAULT 0,
    fecha DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_verificacion DATETIME NULL,
    id_admin_verifica INT NULL,
    CONSTRAINT FK_Reseña_ReservaSalida 
        FOREIGN KEY (id_reserva, id_salida) 
        REFERENCES dbo.Reserva_Salida(id_reserva, id_salida),
    CONSTRAINT FK_Reseña_Turista FOREIGN KEY (id_turista) REFERENCES dbo.Turista(id_turista),
    CONSTRAINT FK_Reseña_Tour FOREIGN KEY (id_tour) REFERENCES dbo.Tour(id_tour),
    CONSTRAINT FK_Reseña_Guia FOREIGN KEY (id_guia) REFERENCES dbo.Guia(id_guia),
    CONSTRAINT UQ_Reseña_ReservaSalida UNIQUE (id_reserva, id_salida),
    -- VALIDACIONES
    CONSTRAINT CHK_Reseña_Comentario CHECK (comentario IS NULL OR LEN(TRIM(comentario)) >= 10), 
    CONSTRAINT CHK_Reseña_FechaVerificacion CHECK (fecha_verificacion IS NULL OR fecha_verificacion >= fecha), 
    CONSTRAINT CHK_Reseña_VerificacionLogica CHECK (
        (verificada = 0 AND fecha_verificacion IS NULL AND id_admin_verifica IS NULL) OR 
        (verificada = 1 AND fecha_verificacion IS NOT NULL AND id_admin_verifica IS NOT NULL)
    ) -- CAMBIO: Si está verificada debe tener fecha y admin
);

GO
CREATE TABLE dbo.Reseña_Multimedia (
    id_reseña_multimedia INT IDENTITY(1,1) PRIMARY KEY,
    id_reseña INT NOT NULL,
    id_multimedia INT NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_ReseñaMultimedia_Reseña FOREIGN KEY (id_reseña) REFERENCES dbo.Reseña(id_reseña),
    CONSTRAINT FK_ReseñaMultimedia_Multimedia FOREIGN KEY (id_multimedia) REFERENCES dbo.Multimedia(id_multimedia),
    CONSTRAINT UQ_Reseña_Multimedia UNIQUE (id_reseña, id_multimedia)
);

GO