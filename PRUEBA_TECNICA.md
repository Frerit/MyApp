# 📝 Prueba Técnica - Desarrollador Senior iOS

## 🎯 Objetivo de la Prueba

Esta prueba técnica evalúa tu capacidad para identificar, analizar y corregir problemas en una aplicación iOS existente. El código contiene **errores intencionales** de diferentes niveles de complejidad que un desarrollador senior debe ser capaz de detectar y resolver.

## ⏱️ Tiempo Estimado

**2-4 horas**

## 📋 Descripción del Proyecto

MyApp es una aplicación iOS de autenticación que incluye:
- Login con email y password
- Autenticación biométrica (Face ID / Touch ID)
- Networking con async/await
- Persistencia de datos con Core Data
- Arquitectura MVVM
- Inyección de dependencias
- Validación de formularios
- Manejo seguro de tokens JWT
- Tests unitarios

## 🔍 Tareas a Realizar

### 1. Identificación de Errores (60%)

Encuentra y documenta TODOS los errores en el código. Los errores están clasificados en:

#### A. Errores Críticos (Bloquean compilación o runtime)
- [ ] Import incorrecto en `ContentView.swift` (línea 8)
- [ ] Modificadores de acceso incorrectos en propiedades (línea 14-15)
- [ ] Binding incorrecto en TextField (línea 49)
- [ ] Componentes SwiftUI inexistentes: `Column` y `Row` (línea 140-142)
- [ ] Falta implementación de `StateObject` y dependencias

#### B. Errores de Arquitectura (Afectan mantenibilidad)
- [ ] Violación de principios SOLID en servicios
- [ ] Inyección de dependencias incompleta
- [ ] Falta de protocolo para NetworkService en algunos lugares
- [ ] Mezcla de lógica de negocio en Views
- [ ] Falta de separación de concerns

#### C. Errores de Seguridad (Riesgo de seguridad)
- [ ] Validación de password incompleta (falta special characters)
- [ ] No hay validación de tamaño máximo de inputs
- [ ] Token JWT decodificado sin validación de firma
- [ ] No hay protección contra ataques de fuerza bruta
- [ ] Falta validación de certificados SSL/TLS en NetworkService
- [ ] Credenciales podrían ser expuestas en logs

#### D. Errores de Rendimiento (Afectan UX)
- [ ] Falta debounce adecuado en validaciones
- [ ] No hay cache de imágenes
- [ ] Queries de Core Data en main thread
- [ ] No hay paginación en fetchAllUsers
- [ ] Memory leaks potenciales con Combine

#### E. Errores de Testing (Coverage incompleto)
- [ ] Faltan tests para casos edge
- [ ] No hay tests de integración completos
- [ ] Mocks incompletos
- [ ] Falta verificación de thread safety
- [ ] No hay tests para errores de red intermitentes

### 2. Corrección de Errores (30%)

Para cada error identificado:
1. Explica **por qué** es un problema
2. Describe el **impacto** que tiene
3. Proporciona la **solución** correcta
4. Explica **mejores prácticas** relacionadas

### 3. Mejoras Propuestas (10%)

Identifica y propone mejoras adicionales:
- [ ] Implementar refresh token automático
- [ ] Agregar manejo de offline mode
- [ ] Implementar rate limiting
- [ ] Agregar analytics y logging
- [ ] Mejorar accesibilidad (VoiceOver)
- [ ] Implementar deep linking
- [ ] Agregar feature flags
- [ ] Implementar CI/CD pipeline

## 🐛 Guía de Errores por Archivo

### ContentView.swift
**Errores a encontrar:**
1. ❌ `import UIKit` en lugar de `import SwiftUI`
2. ❌ Typo en comentario: "Propertiers" → "Properties"
3. ❌ `private var email` sin @State
4. ❌ `private static var password` (static incorrecto)
5. ❌ `TextField("Email", text: password)` - binding a variable incorrecta
6. ❌ `self.$password` - self innecesario y variable estática
7. ❌ `Button { Text(...) }` - Text dentro del action closure
8. ❌ `.edgesIgnoringSafeArea(.all)` deprecated
9. ❌ `Column` y `Row` no existen en SwiftUI
10. ❌ Falta inicialización de dependencias

**Soluciones:**
```swift
// ✅ Correcto:
import SwiftUI

// MARK: - Properties
@State private var email = ""
@State private var password = ""

// TextField correcto
TextField("Email", text: $viewModel.email)

// SecureField correcto
SecureField("Password", text: $viewModel.password)

// Button correcto
Button(action: { /* action */ }) {
    Text("Sign In")
}

// Deprecated modifier
.ignoresSafeArea()

// Correcto: VStack/HStack
VStack {
    LoginView(viewModel: viewModel)
}
```

### NetworkService.swift
**Errores a encontrar:**
1. ❌ No valida certificados SSL
2. ❌ Falta timeout configuration
3. ❌ No maneja redirects adecuadamente
4. ❌ Falta retry logic para errores temporales
5. ❌ No cancela requests duplicados
6. ❌ Headers podrían contener información sensible en logs

**Mejoras necesarias:**
```swift
// ✅ Configuración segura de URLSession
let configuration = URLSessionConfiguration.default
configuration.timeoutIntervalForRequest = 30
configuration.timeoutIntervalForResource = 60
configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

// ✅ Validación de certificados
let session = URLSession(
    configuration: configuration,
    delegate: self, // Implementar URLSessionDelegate
    delegateQueue: nil
)

// ✅ Retry logic
func requestWithRetry<T: Decodable>(
    _ endpoint: Endpoint,
    retries: Int = 3
) async throws -> T {
    // Implementar exponential backoff
}
```

### LoginViewModel.swift
**Errores a encontrar:**
1. ❌ Validación de password no requiere caracteres especiales
2. ❌ No limita intentos de login (brute force)
3. ❌ Expone errores del servidor directamente al usuario
4. ❌ No limpia campos después de error
5. ❌ Falta manejo de estado de red offline

**Mejoras:**
```swift
// ✅ Validación robusta
private let maxLoginAttempts = 5
private var loginAttempts = 0

// ✅ Mensajes de error user-friendly
private func handleError(_ error: Error) {
    switch error {
    case NetworkError.unauthorized:
        errorMessage = "Invalid email or password"
    case NetworkError.noInternetConnection:
        errorMessage = "Please check your internet connection"
    default:
        errorMessage = "Something went wrong. Please try again"
    }
}
```

### AuthenticationService.swift
**Errores a encontrar:**
1. ❌ No invalida tokens anteriores al hacer logout
2. ❌ Falta manejo de concurrent logins
3. ❌ No implementa refresh token automático
4. ❌ Headers de autenticación no incluyen Bearer token
5. ❌ No notifica a observers del estado de autenticación

### KeychainService.swift
**Errores a encontrar:**
1. ❌ No maneja errores de Keychain específicamente
2. ❌ No usa Access Control Flags para biometría
3. ❌ Service identifier podría colisionar
4. ❌ No limpia Keychain en desinstalación
5. ❌ Falta sincronización entre dispositivos (opcional)

**Mejoras:**
```swift
// ✅ Access Control para biometría
let access = SecAccessControlCreateWithFlags(
    nil,
    kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
    .biometryCurrentSet,
    nil
)

// ✅ Error handling detallado
enum KeychainError: Error {
    case itemNotFound
    case duplicateItem
    case invalidData
    case unexpectedStatus(OSStatus)
}
```

### TokenManager.swift
**Errores a encontrar:**
1. ❌ Decodifica JWT sin validar firma
2. ❌ No verifica issuer ni audience
3. ❌ Buffer de expiración hardcoded
4. ❌ No maneja tokens con formato incorrecto
5. ❌ Falta implementación real de refreshToken

**Solución:**
```swift
// ✅ Validación completa de JWT
func validateToken(_ token: String) throws -> JWTPayload {
    // 1. Verificar estructura
    // 2. Validar firma con clave pública
    // 3. Verificar exp, iss, aud
    // 4. Verificar revocación (opcional)
}
```

### BiometricAuthService.swift
**Errores a encontrar:**
1. ❌ Crea nueva instancia de LAContext cada vez
2. ❌ No verifica biometría disponible antes de authenticate
3. ❌ No maneja cambios en biometría enrollada
4. ❌ Falta fallback a device passcode
5. ❌ No localiza mensajes de error

### UserDataManager.swift
**Errores a encontrar:**
1. ❌ Operaciones de Core Data en main thread
2. ❌ No usa NSBatchInsertRequest para bulk operations
3. ❌ Falta error handling robusto
4. ❌ No implementa migration strategy
5. ❌ Queries sin predicados optimizados

**Solución:**
```swift
// ✅ Background context
func saveUser(_ user: User) async throws {
    let context = persistenceController.container.newBackgroundContext()
    try await context.perform {
        // Perform save
    }
}
```

### ValidationService.swift
**Errores a encontrar:**
1. ❌ Regex de email demasiado simple
2. ❌ Password no requiere caracteres especiales
3. ❌ No valida contra lista de passwords comunes
4. ❌ Falta sanitización de inputs
5. ❌ No previene SQL injection en queries

### MyAppTests.swift
**Errores a encontrar:**
1. ❌ Tests no verifican thread safety
2. ❌ Falta cleanup en tearDown
3. ❌ No testa timeouts
4. ❌ Mocks muy simples, no simulan casos reales
5. ❌ No hay tests de UI con ViewInspector
6. ❌ Falta coverage de casos edge

### Fastfile
**Errores a encontrar:**
1. ❌ `scan` y `run_tests` duplicados
2. ❌ No verifica código signing antes de build
3. ❌ Falta manejo de errores
4. ❌ No incrementa build number
5. ❌ No genera changelog
6. ❌ Falta notificación de resultados

**Solución:**
```ruby
lane :build do
  ensure_git_status_clean
  increment_build_number
  run_tests(scheme: "MyApp")
  build_app(scheme: "MyApp")
  upload_to_testflight
  slack(message: "Build uploaded successfully!")
end
```

## 📊 Criterios de Evaluación

| Categoría | Peso | Descripción |
|-----------|------|-------------|
| **Errores Críticos Identificados** | 25% | Encuentra errores que bloquean compilación |
| **Errores de Arquitectura** | 20% | Identifica problemas de diseño |
| **Errores de Seguridad** | 20% | Detecta vulnerabilidades |
| **Calidad de Soluciones** | 20% | Propone soluciones correctas y eficientes |
| **Mejoras y Best Practices** | 15% | Sugiere optimizaciones adicionales |

## 📝 Formato de Entrega

Crea un documento `SOLUCION.md` con el siguiente formato:

```markdown
# Solución - Prueba Técnica iOS Senior

## Desarrollador
- Nombre: [Tu nombre]
- Fecha: [Fecha]
- Tiempo empleado: [X horas]

## 1. Errores Críticos

### Error #1: Import incorrecto en ContentView
**Ubicación:** `ContentView.swift:8`
**Problema:** Se importa `UIKit` en lugar de `SwiftUI`
**Impacto:** El código no compila, `View` protocol no está disponible
**Solución:** 
\```swift
import SwiftUI
\```
**Razón:** ContentView usa componentes de SwiftUI como `VStack`, `Text`, etc.

[Continuar con todos los errores...]

## 2. Mejoras Propuestas

### Mejora #1: Implementar refresh token automático
**Descripción:** [...]
**Beneficio:** [...]
**Implementación sugerida:** [...]

## 3. Preguntas de Arquitectura

### ¿Por qué usar MVVM en lugar de MVC?
[Tu respuesta]

### ¿Cómo mejorarías el manejo de dependencias?
[Tu respuesta]

### ¿Qué patrones de concurrencia usarías?
[Tu respuesta]
```

## 🎁 Bonus Points

- [ ] Implementar las correcciones en código
- [ ] Agregar documentación con DocC
- [ ] Crear diagramas de arquitectura
- [ ] Implementar CI/CD con GitHub Actions
- [ ] Agregar SwiftLint configuration
- [ ] Implementar snapshot testing
- [ ] Crear design system con components reusables

## 📚 Recursos Permitidos

✅ Puedes usar:
- Documentación oficial de Apple
- Stack Overflow
- GitHub repositories como referencia
- Swift.org documentation

❌ No puedes:
- Copiar soluciones de otros candidatos
- Usar AI para generar respuestas completas
- Compartir el test con terceros

## 🔒 Confidencialidad

Esta prueba técnica es confidencial. Por favor no la compartas ni publiques en redes sociales o repositorios públicos.

---

## 📞 Contacto

Si tienes dudas sobre la prueba, contacta a: [email/slack del equipo]

**¡Buena suerte! 🚀**

---

## Resumen de Errores Totales por Categoría

- **Críticos (Compilación/Runtime):** 10 errores
- **Arquitectura:** 8 errores  
- **Seguridad:** 12 errores
- **Rendimiento:** 7 errores
- **Testing:** 8 errores
- **DevOps (Fastfile):** 6 errores

**Total: ~51 errores intencionados** 

Un desarrollador senior debería identificar al menos el 70% (36+ errores) para pasar la prueba.
