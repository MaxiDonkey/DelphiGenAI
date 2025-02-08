[go back](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/README.md#TIPS-for-using-the-tutorial-effectively)
___

- [Abstract](#Abstract)

- [Dependencies](#Dependencies)
- [Asynchronism mechanism](#Asynchronism-mechanism)

<br/>

# Abstract

The presented framework is a comprehensive and extensible solution for Delphi developers looking to integrate modern API calls into their projects, particularly **the latest version of OpenAI APIs**. This version takes advantage of OpenAI’s latest features while offering increased flexibility through HTTP request mocking, robust unit testing, and smooth JSON parameter configuration.

**Key benefits for developers:**
- **Integration of OpenAI APIs (latest version):** The framework is optimized to interact with the latest OpenAI endpoints, supporting content generation services, language models, and other recent innovations.

- **Mocking HTTP requests:** Thanks to the abstraction via the `IHttpClientAPI` interface, developers can easily **mock OpenAI API responses** without making real network calls. This mechanism is especially useful for unit tests to validate different behaviors, including errors or unexpected responses.

- **Unit testing with DUnitX (via the GenAI.API.Tests unit):** The framework integrates with **DUnitX** to allow developers to test various features, such as parameter handling, response deserialization, and error management. The `GenAI.API.Tests` unit provides predefined tests covering common scenarios like validating request parameters (`TUrlParam`), deserializing API objects, and managing errors using exceptions. <br/>
For example:
```Delphi
[Test] procedure Test_TUrlParam_AddParameters;
[Test] procedure Test_TGenAIConfiguration_BuildHeaders;
[Test] procedure Test_TApiDeserializer_Deserialize;
```
This structure makes it easy to create additional tests tailored to specific developer needs.

- **Centralized request management:** The `TGenAIAPI` class simplifies interaction with OpenAI services through standardized methods (GET, POST, DELETE, PATCH), centralizing the construction of requests and the management of responses.

- **Smooth JSON parameter configuration with chaining:** The framework introduces a flexible approach to configure JSON request parameters using method chaining. Developers can chain multiple calls to add successive parameters via methods like `Add()` in the `TJSONParam` class. <br/>
Example:
```Delphi
JSONParam.Add('key1', 'value1').Add('key2', 42).Add('key3', True);
```
This approach makes configuring request data more intuitive and fluid.

- **Automatic deserialization of JSON responses:** API responses are automatically converted into Delphi objects (`TJSONParam`, `TAdvancedList`, etc.), making them easy to manipulate directly in the code.

- **Support for asynchronous operations:** Using types like `TAsynDeletion`, developers can execute non-blocking API calls, maintaining the overall responsiveness of their applications.

- **Flexible request construction and pagination support:** Classes like `TUrlParam` and `TUrlPaginationParams` allow developers to dynamically configure complex requests with options for pagination, sorting, and filtering.

- **Robust error management:** The framework includes detailed error handling through specific exceptions (`TGenAIAPIException`, `TGenAIAuthError`, etc.), making it possible to capture and handle errors related to authentication, quotas, or server responses effectively.
<br/>

**Conclusion** <br>

This framework aims to provide a practical and efficient solution for integrating **OpenAI APIs** into Delphi projects. The support for method chaining in JSON request configuration, combined with unit testing (via **DUnitX** and the `GenAI.API.Tests` unit) and flexible error handling, enables developers to focus on the core business logic of their applications. Although it’s not exhaustive, this framework is designed to evolve with developers’ needs and the technological advancements it supports.

# Dependencies

This Delphi project relies on several key dependencies that cover network functionality, JSON handling,  serialization,  asynchronous operations,  and error management. Here are the main categories of dependencies:

- **Standard Delphi Dependencies:**
Utilizes  native libraries such as  System.Classes,  System.SysUtils,  System.JSON,  and System.Net.HttpClient for general operations, input/output, date management, and network communications.

- **JSON and REST:**
Uses units like REST.Json.Types,  REST.Json.Interceptors, and REST.JsonReflect to handle object serialization/deserialization and REST API calls.

- **Custom Exception and Error Handling:**
Internal modules GenAI.Exceptions and GenAI.Errors capture and propagate errors specific to the API.

- **Custom GenAI API Modules:**
Custom modules like GenAI.API, GenAI.API.Params,  and GenAI.HttpClientInterface are used to build HTTP requests to the GenAI API and handle asynchronous responses.

- **Multithreading and Asynchronous Operations:**
Utilizes System.Threading  and internal classes  (such as TAsynCallBack)  to handle long running tasks and avoid blocking the main thread.

- **Testing Dependencies:**
Uses  DUnitX.TestFramework and  related  modules to implement  unit tests  and  validate critical project functionality.

This  project is structured to be modular and extensible, with  abstractions that  allow for  easily switching  network  libraries  or  adding  new  features  while  maintaining robustness and testability.

# Asynchronism mechanism

### Context and Objectives

The proposed architecture aims to facilitate the management of parameters and the execution of asynchronous operations, particularly for chat requests. Two main units are used:
- GenAI.Async.Params: Provides generic interfaces and classes to manage parameters flexibly and in a reusable manner.
- GenAI.Async.Support: Defines records and classes to control the lifecycle of asynchronous operations, particularly for chat or streaming-based tasks.

The goal is to separate the logic for managing parameters from the logic for asynchronous execution, while ensuring proper synchronization with the main thread (GUI) through callbacks.

### Managing Parameters with Generic Interfaces and Classes

#### Interface IUseParams<T>

This generic interface allows for managing parameters of type T, with the following key methods:

SetParams/GetParams: To set and retrieve the parameter values.
- Assign: Allows assigning values using a function (of type TFunc<T>).
- AsSender: Returns the instance as a TObject, useful for identifying the sender during asynchronous execution.

####  Class TUseParams<T>

Implements the IUseParams<T> interface and encapsulates internal parameter management through a private variable FParams. This provides a simple abstraction for storing and manipulating the parameters required for asynchronous operations.

#### Factory Class TUseParamsFactory<T>

This static factory class creates instances of IUseParams<T>. Two creation methods are provided:
- One method without parameters that creates an empty instance.
- One method that accepts a function of type TFunc<T> to initialize the parameters during creation.

Advantage: Using generics makes it possible to reuse the same mechanism for different parameter types, making the code highly flexible and easily extensible.
