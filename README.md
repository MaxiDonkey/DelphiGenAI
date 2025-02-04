# GenAI for OpenAI

___
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.3/11/12-yellow)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-green)
![GitHub](https://img.shields.io/badge/Updated%20on%20february%2004,%202025-blue)

<br/>
<br/>

- [Introduction](#Introduction)
- [TIPS for using the tutorial effectively](#TIPS-for-using-the-tutorial-effectively)
    - [Obtain an api key](#Obtain-an-api-key)
    - [Strategies for quickly using the code examples](#Strategies-for-quickly-using-the-code-examples)
- [Contributing](#contributing)
- [License](#license)


<br/>
<br/>

# Introduction

Following the development of several wrappers integrating solutions from [Anthropic (Claude)](https://github.com/MaxiDonkey/DelphiAnthropic), [Google (Gemini)](https://github.com/MaxiDonkey/DelphiGemini), [Mistral](https://github.com/MaxiDonkey/DelphiMistralAI), [GroqCloud](https://github.com/MaxiDonkey/DelphiStabilityAI), [Hugging Face](https://github.com/MaxiDonkey/DelphiHuggingFace), and [Deepseek](https://github.com/MaxiDonkey/DelphiDeepseek), `GenAI` now benefits from extensive feedback and experience. This feedback has enabled the creation of an optimized and advanced framework, specifically designed to meet the demands of large-scale projects developed using **Delphi**.

In its latest version, `GenAI` has been primarily optimized to fully leverage OpenAI’s endpoints while remaining easily adaptable for the integration of the other aforementioned wrappers.

<br/>

**Comprehensive Integration with OpenAI** <br/>
- `GenAI` is designed to support the **GPT-4o**, **O1**, and **O3** models, along with the latest developments in `OpenAI’s APIs`. This extensive coverage ensures maximum flexibility for projects leveraging the latest advancements in OpenAI's offerings.

<br/>

**Document Structure** <br/>
- This document is divided into two main sections:

   1. **Quick Start Guide** <br/>
   A practical introduction to generating text or audio responses from various types of inputs:
      - Plain text
      - Image/text combinations
      - Document-based inputs (text)
      - Audio and audio/text data

  2. **Advanced Features in a Cookbook Format**
      - A detailed guide showcasing advanced features available through OpenAI, complete with practical code examples for easy integration into your applications.

<br/>

**Technical Support and Code Examples**<br/>
- Two support units, **VCL** and **FMX**, are included in the provided sources. These units simplify the implementation of the code examples and facilitate learning, with a focus on best practices for using `GenAI`.

For more information about the architecture of GenAI, please refer to [the dedicated page](https://github.com/MaxiDonkey/DelphiGenAI/blob/main/GenAI.md). 


<br/>

# TIPS for using the tutorial effectively

## Obtain an api key

To initialize the API instance, you need to obtain an [API key from OpenAI](https://platform.openai.com/settings/organization/api-keys)

Once you have a token, you can initialize IGenAI interface, which is an entry point to the API.

>[!NOTE]
>```Delphi
>//Declare 
>//  Client: IGenAI;
>
>  Client := TGenAIFactory.CreateInstance(api_key);
>```

<br/>

>[!TIP]
> To effectively use the examples in this tutorial, particularly when working with asynchronous methods, it is recommended to define the client interfaces with the broadest possible scope. For optimal implementation, these clients should be declared in the application's `OnCreate` method.
>

<br>

## Strategies for quickly using the code examples

To streamline the implementation of the code examples provided in this tutorial, two support units have been included in the source code: `Deepseek.Tutorial.VCL` and `Deepseek.Tutorial.FMX` Based on the platform selected for testing the provided examples, you will need to initialize either the `TVCLTutorialHub` or `TFMXTutorialHub` class within the application's OnCreate event, as illustrated below:

>[!NOTE]
>```Delphi
>//uses GenAI.Tutorial.VCL;
>  TutorialHub := TVCLTutorialHub.Create(Client, Memo1, Memo2, Memo3, Image1, Button1, MediaPlayer1);
>```

or

>[!NOTE]
>```Delphi
>//uses GenAI.Tutorial.FMX;
>  TutorialHub := TFMXTutorialHub.Create(Client, Memo1, Memo2, Memo3, Image1, Button1, MediaPlayer1);
>```

Make sure to add a three ***TMemo***, a ***TImage***, a ***TButton*** and a ***TMediaPlayer*** components to your form beforehand.

The TButton will allow the interruption of any streamed reception.

<br/>

# Contributing

Pull requests are welcome. If you're planning to make a major change, please open an issue first to discuss your proposed changes.

# License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.