# 📝 Prueba Técnica - Desarrollador Senior iOS

## 🎯 Objetivo de la Prueba

Esta prueba técnica evalúa tu capacidad para identificar, analizar y corregir problemas en una aplicación iOS existente. El código contiene **errores intencionales** de diferentes niveles de complejidad que un desarrollador senior debe ser capaz de detectar y resolver.

## ⏱️ Tiempo Estimado

**30 minutos**

## 📋 Descripción del Proyecto

MyApp es una aplicación iOS de autenticación simple que incluye:
- Login con email y password
- Networking con async/await
- Arquitectura MVVM básica
- Almacenamiento seguro con Keychain
- Validación de formularios
- Tests unitarios

## 🔍 Tareas a Realizar

### 1. Identificación de Errores (60%)

Encuentra y documenta TODOS los errores en el código. Los errores están clasificados en:

#### A. Errores Críticos (Bloquean compilación o runtime)
- [ ] Import incorrecto en `ContentView.swift` (línea 8)
- [ ] Modificadores de acceso incorrectos en propiedades (línea 12-14)
- [ ] Binding incorrecto en TextField (línea ~58)
- [ ] Uso de `self.$` innecesario en SecureField
- [ ] Componentes SwiftUI inexistentes: `Column` y `Row`
- [ ] Button con sintaxis incorrecta (Text dentro del closure de action)

#### B. Errores de Arquitectura (Afectan mantenibilidad)
- [ ] Falta inicialización del ViewModel en ContentView
- [ ] LoginView requiere parámetro pero ContentView no lo pasa
- [ ] Mezcla de lógica de UI en el action del Button

#### C. Errores de Seguridad (Riesgo de seguridad)
- [ ] No hay validación de email antes de enviar al servidor
- [ ] Password mínimo muy corto (debería ser 8+ caracteres)
- [ ] Falta timeout en NetworkService
- [ ] No se invalida token en el servidor al hacer logout
- [ ] Keychain no maneja errores de OSStatus

#### D. Errores de API Deprecated
- [ ] `.edgesIgnoringSafeArea(.all)` está deprecated, usar `.ignoresSafeArea()`

#### E. Errores de Testing
- [ ] Faltan tests para casos edge (email vacío, contraseña corta)
- [ ] No se prueban errores de red
- [ ] Falta verificar que se guarda el token en Keychain

### 2. Corrección de Errores (30%)

Para cada error identificado:
1. Explica **por qué** es un problema
2. Describe el **impacto** que tiene
3. Proporciona la **solución** correcta
4. Explica **mejores prácticas** relacionadas

### 3. Mejoras Propuestas (Bonus)

Identifica y propone mejoras adicionales:
- [ ] Agregar validación de email en tiempo real
- [ ] Implementar rate limiting para prevenir brute force
- [ ] Agregar indicador de carga durante login
- [ ] Implementar retry automático en caso de error de red
- [ ] Agregar logging para debugging
- [ ] Mejorar mensajes de error para el usuario
- [ ] Implementar timeout configurable
- [ ] Agregar tests de UI

## 🐛 Guía de Errores por Archivo

### ContentView.swift (10 errores críticos)
**Errores a encontrar:**
1. ❌ **Línea 8:** `import UIKit` en lugar de `import SwiftUI`
2. ❌ **Línea 12:** Typo: "Propertiers" → "Properties"
3. ❌ **Línea 13:** `private var email` sin @State
4. ❌ **Línea 14:** `private static var password` (static incorrecto + sin @State)
5. ❌ **Línea ~58:** `TextField("Email", text: password)` - binding sin $ y variable incorrecta
6. ❌ **Línea ~69:** `text: self.$password` - self innecesario + binding a variable estática
7. ❌ **Línea ~85:** `Button { Text(...) }` - Text dentro del action en lugar de label
8. ❌ **Línea ~32:** `.edgesIgnoringSafeArea(.all)` API deprecated (usar `.ignoresSafeArea()`)
9. ❌ **Líneas ~180-184:** `Column` y `Row` no existen en SwiftUI (usar VStack/HStack)
10. ❌ **Línea ~183:** `LoginView()` sin pasar viewModel requerido

**Soluciones:**
```swift
// ✅ Correcto:
import SwiftUI

// MARK: - Properties
@StateObject private var viewModel: LoginViewModel
@State private var showingSignUp = false

// TextField correcto con binding al viewModel
TextField("Email", text: $viewModel.email)

// SecureField correcto sin self
SecureField("Password", text: $viewModel.password)

// Button correcto con action y label separados
Button(action: {
    Task {
        await viewModel.login()
    }
}) {
    Text("Sign In")
        .font(.headline)
        .foregroundColor(.white)
}

// API actualizada
.ignoresSafeArea()

// Correcto: VStack con viewModel
VStack {
    LoginView(viewModel: viewModel)
}
```

### NetworkService.swift (3 errores)
**Errores a encontrar:**
1. ❌ No configura timeout en URLSession (debería tener `timeoutIntervalForRequest`)
2. ❌ Validación de password demasiado simple (solo verifica no vacío, debería validar longitud mínima)
3. ❌ No maneja errores de red específicos (timeout, no internet, etc.)

**Mejoras necesarias:**
```swift
// ✅ Agregar timeout
class NetworkService {
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
}

// ✅ Validación de password mejorada
func login(email: String, password: String) async throws -> LoginResponse {
    guard password.count >= 8 else {
        throw NetworkError.invalidResponse
    }
    // ... resto del código
}

// ✅ Manejo de errores específicos
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError
    case timeout
    case noInternetConnection
}
```

### LoginViewModel.swift (2 errores)
**Errores a encontrar:**
1. ❌ No valida formato de email antes de enviar (debería usar regex)
2. ❌ No limita intentos de login fallidos (vulnerable a brute force)

**Mejoras:**
```swift
// ✅ Validación de email con regex
func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}

// ✅ Limitar intentos de login
private var loginAttempts = 0
private let maxAttempts = 5

func login() async {
    guard loginAttempts < maxAttempts else {
        errorMessage = "Too many failed attempts"
        return
    }
    // ... código de login
    if failed {
        loginAttempts += 1
    } else {
        loginAttempts = 0
    }
}
```

### AuthenticationService.swift (2 errores)
**Errores a encontrar:**
1. ❌ No invalida token en el servidor al hacer logout (solo elimina localmente)
2. ❌ Comentario TODO indica funcionalidad faltante pero crítica

### KeychainService.swift (2 errores)
**Errores a encontrar:**
1. ❌ No maneja errores de OSStatus del Keychain (SecItemAdd puede fallar)
2. ❌ Comentario TODO sobre Access Control para biometría sin implementar

**Mejoras:**
```swift
// ✅ Error handling completo
func save(key: String, value: String) throws {
    guard let data = value.data(using: .utf8) else {
        throw KeychainError.invalidData
    }
    
    delete(key: key)
    
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        throw KeychainError.unexpectedStatus(status)
    }
}

enum KeychainError: Error {
    case invalidData
    case unexpectedStatus(OSStatus)
}
```

### MyAppTests.swift (3 errores)
**Errores a encontrar:**
1. ❌ Falta test para validar que el token se guarda en Keychain después de login exitoso
2. ❌ No hay test para email vacío o inválido
3. ❌ Falta test para verificar comportamiento cuando NetworkService falla

**Mejoras necesarias:**
```swift
// ✅ Agregar tests faltantes
func testTokenIsSavedAfterLogin() async throws {
    let response = try await sut.login(email: "test@example.com", password: "password123")
    
    XCTAssertNotNil(mockKeychainService.get(key: "auth_token"))
    XCTAssertEqual(mockKeychainService.get(key: "auth_token"), response.token)
}

func testLoginWithEmptyEmail() async {
    sut.email = ""
    sut.password = "password123"
    
    await sut.login()
    
    XCTAssertNotNil(sut.errorMessage)
    XCTAssertFalse(sut.isAuthenticated)
}
```

### Fastfile (2 errores)
**Errores a encontrar:**
1. ❌ `scan` y `run_tests` están duplicados (hacen lo mismo)
2. ❌ No incrementa build number automáticamente

**Solución:**
```ruby
lane :build do
  increment_build_number
  run_tests(scheme: "MyApp")
  build_app(scheme: "MyApp")
  upload_to_testflight
end
```

## 📊 Criterios de Evaluación

| Categoría | Peso | Descripción |
|-----------|------|-------------|
| **Errores Críticos Identificados** | 40% | Encuentra los 10 errores que bloquean compilación |
| **Errores de Arquitectura** | 15% | Identifica 3 problemas de diseño |
| **Errores de Seguridad** | 25% | Detecta 5 vulnerabilidades |
| **Errores de Testing** | 10% | Identifica 3 gaps en tests |
| **Calidad de Soluciones** | 10% | Propone soluciones correctas |

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
- [ ] Agregar validación de email con regex en LoginViewModel
- [ ] Implementar rate limiting para login
- [ ] Agregar timeout configuration en NetworkService
- [ ] Escribir los 3 tests faltantes
- [ ] Corregir el Fastfile

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

- **Críticos (Compilación/Runtime):** 6 errores
- **Arquitectura:** 3 errores  
- **Seguridad:** 5 errores
- **API Deprecated:** 1 error
- **Testing:** 3 errores
- **DevOps (Fastfile):** 2 errores

**Total: ~20 errores intencionados** 

Un desarrollador senior debería identificar al menos 14+ errores (70%) en 30 minutos para pasar la prueba.
