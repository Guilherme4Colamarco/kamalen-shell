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

## Próximas fases (planejadas)

- **Fase 3:** Agrupar right cluster com separators sutis
- **Fase 4:** Padronizar hover (eliminar underline restante)
- **Fase 5:** Tooltips em todos os botões
- **Fase 6:** Clock com data opcional (hover expande)
