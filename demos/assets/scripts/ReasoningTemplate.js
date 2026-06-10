(function () {

  const container = document.getElementById("ResponseContent");
  if (!container) return;

  if (document.getElementById("loadingBubble")) return;

  if (!document.getElementById("reasoning-style")) {

    const style = document.createElement("style");
    style.id = "reasoning-style";

    style.textContent = `
    .chat-bubble.reasoning{
        min-width:140px;
        max-width:140px;
        /*max-width:38%;*/
        position:relative;
        overflow:hidden;
        background: var(--bg-main, transparent) !important;
        border:none !important;
        border-radius:10px;
        padding: 0 0px 12px 16px;
        /*padding:12px 16px;*/
        color:var(--reasoning-text,#d8dbe0);
        display:flex;
        align-items:center;
        box-shadow:none;
        animation: reasoningFade .65s ease;
        font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif;
    }

    /* shimmer effect */

    .chat-bubble.reasoning::after{

        content:"";

        position:absolute;
        top:0;
        left:-150%;

        width:50%;
        height:100%;

        background:linear-gradient(
            90deg,
            transparent,
            var(--reasoning-shimmer,rgba(255,255,255,0.07)),
            transparent
        );

        animation:reasoningShimmer 2.2s infinite;

    }

    .reasoning-container{

        display:flex;
        align-items:center;
        gap:10px;
        width:100%;

    }

    .reasoning-text{

        font-weight:500;
        font-size:0.95rem;

        color:var(--reasoning-text-secondary,#cfd4dc);

    }

    .reasoning-icon{

        width:14px;
        height:14px;

        border-radius:50%;

        background:var(--reasoning-accent,#4c8dff);

        box-shadow:0 0 8px var(--reasoning-accent-glow,rgba(76,141,255,0.5));

        animation:pulse 2s infinite;

        flex-shrink:0;

    }

    .reasoning-dots{

        display:flex;
        gap:4px;

        margin-left:auto;

    }

    .reasoning-dots span{

        width:4px;
        height:4px;

        border-radius:50%;

        background:var(--reasoning-dots,#7b8088);

        animation:dotPulse 1.4s infinite;

    }

    .reasoning-dots span:nth-child(2){animation-delay:.2s;}
    .reasoning-dots span:nth-child(3){animation-delay:.4s;}

    @keyframes reasoningShimmer{

        0%{ left:-150%; }
        100%{ left:150%; }

    }

    @keyframes dotPulse{

        0%,80%,100%{

            opacity:.25;
            transform:scale(.85);

        }

        40%{

            opacity:1;
            transform:scale(1.2);

        }

    }

    @keyframes pulse{

        0%{

            box-shadow:0 0 6px var(--reasoning-accent-glow,rgba(76,141,255,0.4));

        }

        50%{

            box-shadow:0 0 12px var(--reasoning-accent-glow,rgba(76,141,255,0.8));

        }

        100%{

            box-shadow:0 0 6px var(--reasoning-accent-glow,rgba(76,141,255,0.4));

        }

    }

    @keyframes reasoningFade{

        from{

            opacity:0;
            transform:translateY(6px);

        }

        to{

            opacity:1;
            transform:translateY(0);

        }

    }

    `;

    document.head.appendChild(style);
  }

  /* create bubble */

  const wrapper = document.createElement("div");
  wrapper.className = "assistant-message";

  const bubble = document.createElement("div");
  bubble.id = "loadingBubble";
  bubble.className = "chat-bubble assistant reasoning";

  bubble.innerHTML = `
      <div class="reasoning-container">
          <div class="reasoning-icon"></div>
          <div class="reasoning-text">Reasoning</div>
          <div class="reasoning-dots">
              <span></span>
              <span></span>
              <span></span>
          </div>
      </div>
  `;

  wrapper.appendChild(bubble);
  container.appendChild(wrapper);

  container.scrollTop = container.scrollHeight;

})();
