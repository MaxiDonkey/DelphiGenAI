# Realtime

- [Realtime API Reference](#realtime-api-reference)
- [Edge-OpenAI-Realtime Project](#edge-openai-realtime-project)
- [Using a Third-Party WebRTC Component](#using-a-third-party-webrtc-component)
- [Roadmap and Future Enhancements](#roadmap-and-future-enhancements)
___

## Realtime API Reference

The current Delphi wrapper for `OpenAI APIs` does not provide support for the Realtime API.

The **Realtime API** is built on **WebRTC**, a technology that falls outside the scope of the DelphiGenAI wrapper.

However, an implementation of Realtime is available in a separate project:  
[**Edge-OpenAI-Realtime**](https://github.com/MaxiDonkey/Edge-OpenAI-Realtime).

The relevant source code is located in:  
[`source/realtime`](https://github.com/MaxiDonkey/Edge-OpenAI-Realtime/tree/main/source/realtime)

<p align="center">
  <img src="https://github.com/MaxiDonkey/DelphiGenAI/blob/main/images/Realtime-VCL-Component.png?raw=true" width="300"/>
</p>

<br>

## Edge-OpenAI-Realtime Project

**Edge-OpenAI-Realtime is a VCL component** based on **Microsoft Edge (WebView2)**, which provides native access to WebRTC.

This project includes:
- A VCL component encapsulating WebView2 with WebRTC support,
- A functional implementation of the OpenAI Realtime API,
- A clear separation between the Realtime logic and the WebRTC layer.

<br>

## Using a Third-Party WebRTC Component

The Realtime implementation does not strictly require **Edge/WebView2**.

The project defines an abstract WebRTC interface in:  
[`WebRTC.Core.pas`](https://github.com/MaxiDonkey/Edge-OpenAI-Realtime/blob/main/source/realtime/WebRTC.Core.pas)

To use a third-party WebRTC engine, an adapter must be created that implements this interface.  
Once implemented, the existing Realtime logic can operate through that adapter without modification.

The Edge-OpenAI-Realtime project serves as a didactic and functional reference for understanding how Realtime operates with WebRTC.

<br>

## Roadmap and Future Enhancements

OpenAI has recently introduced the **ChatKit APIs** (currently in beta), which allow developers to create **custom conversational contexts**.

These capabilities are intended to improve the accuracy and relevance of Realtime by enabling:
- Application-specific or user-specific conversational contexts,
- Integration of structured knowledge or persistent state,
- Seamless use of advanced tools within an active Realtime session.

This is particularly relevant for technologies such as:
- **MCP (Model Context Protocol)** server-side tools,
- **Deep Research** and autonomous reasoning workflows,
- Other advanced toolchains requiring contextual awareness during realtime interaction.

As ChatKit evolves beyond beta, the Realtime wrapper is expected to be extended to support:
- Creation and lifecycle management of ChatKit contexts,
- Associating Realtime sessions with predefined or dynamic contexts,
- Optional integration hooks for MCP servers, retrieval systems, or external reasoning engines.

**The Edge-OpenAI-Realtime component is planned to be updated to include ChatKit support in a future release.**