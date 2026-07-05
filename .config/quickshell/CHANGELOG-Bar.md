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

- **Fase 2:** Agrupar right cluster com separators sutis
- **Fase 3:** Padronizar hover (eliminar underline restante)
- **Fase 4:** Tooltips em todos os botões
- **Fase 5:** Clock com data opcional (hover expande)
