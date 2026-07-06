# Bar.qml — Changelog de Remodelação

Registro incremental de mudanças. Cada entrada = uma fase testada e funcionando.

---

## Fase 0 — Polish de interatividade (pré-refactor)
**Data:** 5 jul 2026

| Widget | Mudança |
|---|---|
| WiFi | Text morto → click toggle on/off + hover circle accent/red |
| Bluetooth | Text morto → click power toggle + hover circle |
| Volume | Adicionado hover scale + underline accent (consistente com clock) |
| Battery | `batMa` dead code → click abre dashboard |

---

## Fase 2 — Tray refactor + PopupBase (inspirado no meloworld-dotfiles)
**Data:** 5 jul 2026

**Problema:**
- Tray inline duplicado em Bar.qml e IslandContent.qml (~100 linhas × 2)
- `TrayPopup.qml` tinha bug crítico: `visible` binding lutava com WM para fechar, `onClosed()` nunca chamado
- `TrayState.hide()` não limpava `activeItem` (memory leak)
- `QsWindow.window` acessado sem null-guard → crash potencial

**Solução:**
1. **PopupBase.qml** — componente base com state machine (`closed`→`open`→`closing`→`closed`), slide-down + fade animado, auto-dismiss timer, estética Kamalen (Colors/Animations/UIState)
2. **TrayState.qml** — `hide()` limpa `activeItem` + `parentWindow`; adicionado `closeAll()`
3. **TrayPopup.qml** — reescrito usando `PopupBase`; `visible` controlado por `animState` (não binding); conectado a `onAboutToHide`
4. **TrayBar.qml** — componente extraído (80 linhas), configável (`iconPx`, `itemPx`, `itemH`, `itemRadius`, `itemSpacing`), null-safe `QsWindow?.window`
5. **Bar.qml / IslandContent.qml** — substituídos por `TrayBar {}`
6. **qmldir** — registrado `PopupBase` e `TrayBar`

**Resultado:**
- Código duplicado eliminado (~180 linhas)
- Tray popup fecha corretamente (clique fora, auto-dismiss 3s)
- Memory leak corrigido
- Crash potential eliminado
- Configuração consistente entre barra e island

---

## Fase 2b — Bugfix: PopupBase crash (onAboutToHide inexistente)
**Data:** 5 jul 2026

**Problema:**
- `PopupBase.qml` usava `onAboutToHide` que não existe em `PopupWindow`
- Verificado via qmltypes: `ProxyPopupWindow` não exporta esse signal
- Resultado: shell crashava ao recarregar

**Solução:**
- Removido `onAboutToHide: { animState = "closing" }`
- Fechamento já é tratado por `TrayPopup.Connections` → `animState = "closing"`
- `mask: Region { item: innerRect }` mantido (válido — `Quickshell/Region 0.0`)

**Resultado:**
- Shell recarrega sem crash
- Tray popup funciona: abre via TrayBar, fecha via auto-dismiss / clique fora

---

## Fase 1 — PillButton component (DRY refactor)
**Data:** 5 jul 2026

**Problema:** Padrão hover-circle (Item + Rectangle + Text + MouseArea = ~33 linhas) duplicado 4× (WiFi, BT, Power, Dashboard).

**Solução:** Componente `PillButton.qml` reutilizável (58 linhas, API limpa).

**Migração:**
- ✅ WiFi → PillButton (37→9 linhas)
- ✅ Bluetooth → PillButton (33→9 linhas)
- ✅ Power → PillButton (34→9 linhas)
- ✅ Dashboard → PillButton (34→9 linhas)

**Resultado:**
- Bar.qml: 958 → 868 linhas (−90)
- 4 instâncias de PillButton, zero código duplicado
- Registrado em `qmldir` como `PillButton 1.0`
- API: `icon`, `iconSize`, `active`, `activeColor`, `inactiveColor`, `hoverColor`, `activeOpacity`, `inactiveOpacity`, signal `clicked(mouse)`

**PillButton API:**
```qml
PillButton {
    icon: wifi ? "󰤨" : "󰤭"
    iconSize: 13
    active: wifi
    activeColor: Colors.accent
    inactiveColor: Colors.fg
    hoverColor: Colors.accent     // cor do bg circle no hover
    onClicked: wifiToggle.running = true
}
```

---

---

## Fase 3 — Pill/island bar mode + Dashboard tabs
**Data:** 6 jul 2026

**Problema:**
- Barra só tinha estilos full-width (`fixed`, `floating`, `autohide`)
- Usuário queria um modo "pill/island" centralizado, compacto, como no reddit r/hyprland
- Dashboard era uma coluna monolítica; difícil achar configurações

**Solução:**
1. **Bar.qml — modo `pill`**
   - Novo `barMode: "pill"` (ciclo: fixed → floating → autohide → pill)
   - `PillBarContent` component: pill centralizado, largura ajustada ao conteúdo
   - Layout: bateria + WiFi | tags 1-5 | BT + volume + clock + dashboard
   - Fontes e espaçamento reduzidos; tags menores (14×14)
   - Background com `radius: 14`, borda sutil, animação de entrada
2. **Dashboard.qml — abas**
   - Tab bar com 5 abas: Quick, Display, Media, System, Look
   - **Quick:** quick-settings grid + notificações
   - **Display:** brilho, blur, border radius
   - **Media:** volume, animações
   - **System:** uptime, power mode, bar mode
   - **Look:** tema dark/light, transparência, avatar
   - Novos componentes reutilizáveis: `TileButton`, `InfoRow`
3. **UIState.qml**
   - `barMode` agora aceita `"pill"`
   - save/load atualizados

**Resultado:**
- Estilo pill/island funcional e centralizado
- Dashboard organizado por categorias
- Ciclo de bar mode inclui pill

---

## Fase 3b — Ajuste de tamanho da barra pill
**Data:** 6 jul 2026

**Mudança:**
- Aumentada barra pill: 56px de altura total, pill de 40px
- Fontes e ícones aumentados (10–14px)
- Tags maiores (20×20) e espaçamento mais confortável
- Margens internas e externas maiores

**Resultado:**
- Barra pill mais legível e visualmente próxima à referência

---

## Fase 8 — Configuração do MangoWM pelo shell (Phase 1)
**Data:** 6 jul 2026

**Objetivo:** Permitir configurar o MangoWM diretamente pela interface do shell, com aplicação ao vivo.

**Solução:**
1. **Backend Python `~/.config/mango/mango_config.py`**
   - Parser/writer robusto do formato `key=value` do MangoWM
   - CLI: `get`, `set`, `set-apply`, `apply`, `set-many`, `set-module`, `reload`, `validate`, `migrate`
   - Preserva comentários e ordem nos arquivos
   - Detecta socket do Mango automaticamente via `MANGO_INSTANCE_SIGNATURE` ou glob
2. **Configuração modular do Mango**
   - `config.conf` passou a conter apenas `source=conf.d/*.conf`
   - Cada categoria em seu próprio arquivo: `gaps.conf`, `borders.conf`, `blur.conf`, `shadows.conf`, `animations.conf`, `colors.conf`, `focus.conf`, `input-*.conf`, `binds.conf`, `windowrules.conf`, `monitors.conf`, etc.
   - Backup automático do `config.conf` original
3. **Singleton QML `MangoConfig.qml`**
   - Registrado em `qmldir`
   - Propriedades reativas: gaps, borders, blur, shadows, opacity, input, focus
   - `MangoConfig.set(key, value)` persiste + aplica ao vivo via `mmsg setoption`
   - `MangoConfig.setModule(module, pairs)` para updates em lote
4. **Refactor de `UIState.qml`**
   - `setBorderRadius`, `applyMangoAnimations`, `applyMangoBlur`, `updateMangoOpacity`, `updateMangoBorderColors` agora usam o backend Python em vez de `sed -i` frágil
   - Isso torna compatível com a configuração modular e permite chaves novas

**Resultado:**
- MangoWM configurável programaticamente pelo shell
- Aplicação ao vivo sem recarregar tudo (para options que suportam `setoption`)
- Base pronta para a aba "Mango" no Dashboard (Phase 2)
- Validação `mango -p` limpa após remover entradas stale

---

## Próximas fases (planejadas)

- **Fase 4:** Padronizar hover (eliminar underline restante)
- **Fase 5:** Tooltips em todos os botões
- **Fase 6:** Clock com data opcional (hover expande)
- **Fase 7:** Mais estilos de barra (blur, liquid, TUI, ctOS)
- **Fase 9:** Aba "Mango" no Dashboard com sliders/toggles para todas as opções
