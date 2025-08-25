# npu-verilog

**Versão Verilog da arquitetura NPU V7.1**  
Baseado no datasheet *"NPU V7.1 Datasheet + User Manual"* desenvolvido por Tianchen Yu, Tianrui Wang, Yufei Jin e Peter Kinget (Columbia University, 2023).

---

## 📂 Estrutura do repositório

```
npu-verilog/
├── README.md
├── LICENSE
├── docs/
│   └── NPU_V7.1_Datasheet.pdf
├── rtl/
│   ├── npu_top.v
│   ├── mac.v
│   ├── relu.v
│   ├── piso.v
│   ├── fifo.v
│   └── mux_out.v
├── tb/
│   ├── tb_npu_top.v
│   └── tb_mac.v
└── .gitignore
```

---

## 🎯 Objetivo

Implementar em **Verilog** os módulos principais da NPU V7.1:

- **MAC (Multiplicador–Acumulador)** com entrada de bias via MUX e saturação.  
- **ReLU** configurável, com sinais de bypass (`BYPASS_ReLU1/2`) e enable (`EN_ReLU`).  
- **PISO_OUT** para conversão de dois outputs de 16 bits em quatro de 8 bits.  
- **FIFO de saída** (128 profundidade) com flags `FULL` e `EMPTY`.  
- **MUX de saída** com seleção `SEL_OUT[2:0]` entre FIFO, PISO_OUT, comparador etc.  
- **NPU_TOP** integrando todos os módulos com controle via registradores e sinais de estado.  

---

## ⚙️ Como usar

### Requisitos
- Simulador HDL: Icarus Verilog, ModelSim ou Verilator  

---

## 🔑 Módulos principais

| Módulo       | Função |
|--------------|--------|
| `mac.v`      | Unidade de multiplicação e acumulação com saturação. |
| `relu.v`     | ReLU configurável, permite bypass ou ativação seletiva. |
| `piso.v`     | Parallel-Input Serial-Output para reorganizar saídas. |
| `fifo.v`     | FIFO síncrona (128 entradas), flags `FULL`/`EMPTY`. |
| `mux_out.v`  | Multiplexador de saída controlado por `SEL_OUT[2:0]`. |
| `npu_top.v`  | Módulo principal, integra todos os blocos e sinais de controle. |

---

## 🚀 Próximos passos

- Adicionar comparador para seleção de maior valor.  
- Expandir testbenches cobrindo todos os modos operacionais.  
- Gerar documentação detalhada de sinais e temporizações.  
- Implementar versão sintetizável em FPGA.  

---

## 📜 Licença

Este projeto pode ser distribuído sob a licença **MIT**, **BSD 3-Clause** ou **Apache 2.0** (a definir).  

---

## 📖 Referências

1. Datasheet e manual de usuário *NPU V7.1* — Tianchen Yu et al., Columbia University, 2023.  
   [Página do projeto](https://www.ee.columbia.edu/~kinget/EE6350_S23/team08_npu_website/architecture.html)

---

## 🤝 Contribuições

Contribuições são bem-vindas!  
Abra uma *issue* ou *pull request* com suas melhorias, correções ou sugestões.
