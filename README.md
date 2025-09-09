# NPU (Neural Processing Unit) - Implementação Verilog

Este projeto contém a implementação completa em Verilog de uma NPU (Neural Processing Unit) baseada na arquitetura NPU V7.1, incluindo todos os módulos necessários para processamento de redes neurais.

## 📁 Estrutura do Projeto

```
presenca_semana/
├── README.md                           # Este arquivo
├── compile_script.bat                  # Script de compilação básica
├── compile_npu_complete.bat           # Script de compilação completa
├── compile_simple.bat                 # Script de compilação simplificada
├── testbench_npu_complete.v           # Testbench principal
├── trabalho/
│   └── npu_verilog/
│       ├── rtl/                       # Módulos RTL (Register Transfer Level)
│       │   ├── npu_top.v             # Módulo principal da NPU
│       │   ├── fsm_top.v             # Máquina de estados principal
│       │   ├── mac_module.v          # Módulo MAC (Multiplicador-Acumulador)
│       │   ├── relu_module.v         # Módulo ReLU (Rectified Linear Unit)
│       │   ├── auto_comparator.v     # Comparador automático
│       │   ├── input_buffer.v        # Buffer de entrada
│       │   ├── fifo.v                # FIFO de saída
│       │   ├── piso_out.v            # Conversor Parallel-In Serial-Out
│       │   ├── piso_deb.v            # PISO para debug
│       │   └── mux.v                 # Multiplexador
│       ├── tb/                       # Testbenches
│       │   ├── tb_npu_top.v          # Testbench do módulo principal
│       │   ├── tb_mac_module.v       # Testbench do MAC
│       │   ├── tb_input_buffer.v     # Testbench do buffer de entrada
│       │   ├── tb_piso_out.v         # Testbench do PISO
│       │   ├── tb_piso_deb.v         # Testbench do PISO debug
│       │   ├── tb_mux.v              # Testbench do multiplexador
│       │   ├── fifo_tb.v             # Testbench da FIFO
│       │   └── test_relu_autocomp.v  # Testbench ReLU e Comparador
│       └── docs/
│           ├── NPU_V7.1_Datasheet.pdf # Documentação da NPU
│           └── relatorio_de_desenvolvimento.docx
└── work/                              # Arquivos de trabalho do ModelSim
```

## 🎯 Funcionalidades Implementadas

### Módulos Principais

| Módulo | Função | Características |
|--------|--------|-----------------|
| **npu_top.v** | Módulo principal | Integra todos os componentes da NPU |
| **fsm_top.v** | Controlador FSM | Máquina de estados para controle da operação |
| **mac_module.v** | MAC | Multiplicador-Acumulador com saturação |
| **relu_module.v** | ReLU | Função de ativação com bypass opcional |
| **auto_comparator.v** | Comparador | Comparação automática de valores |
| **input_buffer.v** | Buffer de entrada | Armazenamento temporário de dados |
| **fifo.v** | FIFO | Fila de saída com flags FULL/EMPTY |
| **piso_out.v** | PISO | Conversão de dados paralelos para seriais |
| **mux.v** | Multiplexador | Seleção de saídas |

### Características Técnicas

- **Largura de dados**: 8 bits (entrada) / 16 bits (processamento interno)
- **Clock**: Síncrono (borda de subida)
- **Reset**: Global assíncrono
- **Saturação**: Implementada no MAC para evitar overflow
- **Bypass**: Suportado no módulo ReLU
- **Estados FSM**: IDLE, LOAD_INPUT, COMPUTE, RELU_STAGE, WRITE_FIFO, OUTPUT_SHIFT, DEBUG_MODE, FINISH

## 🚀 Como Usar

### Requisitos
- **ModelSim** (ou outro simulador Verilog compatível)
- **Windows** (para os scripts .bat)

### Compilação e Simulação

#### Opção 1: Compilação Completa (Recomendada)
```bash
# Execute o script de compilação completa
compile_npu_complete.bat
```

#### Opção 2: Compilação Básica
```bash
# Execute o script de compilação básica
compile_script.bat
```

#### Opção 3: Compilação Manual
```bash
# Criar biblioteca de trabalho
vlib work

# Compilar módulos na ordem correta
vlog trabalho/npu_verilog/rtl/input_buffer.v
vlog trabalho/npu_verilog/rtl/mac_module.v
vlog trabalho/npu_verilog/rtl/relu_module.v
vlog trabalho/npu_verilog/rtl/auto_comparator.v
vlog trabalho/npu_verilog/rtl/fifo.v
vlog trabalho/npu_verilog/rtl/piso_out.v
vlog trabalho/npu_verilog/rtl/piso_deb.v
vlog trabalho/npu_verilog/rtl/mux.v
vlog trabalho/npu_verilog/rtl/fsm_top.v
vlog trabalho/npu_verilog/rtl/npu_top.v

# Compilar testbench
vlog testbench_npu_complete.v

# Executar simulação
vsim -c -do "run -all; quit" testbench_npu_complete
```

## 🧪 Testbenches Disponíveis

- **testbench_npu_complete.v**: Testbench principal do sistema completo
- **tb_npu_top.v**: Testbench do módulo principal
- **tb_mac_module.v**: Testbench do módulo MAC
- **tb_input_buffer.v**: Testbench do buffer de entrada
- **tb_piso_out.v**: Testbench do conversor PISO
- **fifo_tb.v**: Testbench da FIFO
- **test_relu_autocomp.v**: Testbench dos módulos ReLU e Comparador

## 📊 Sinais de Interface

### Entradas Principais
- `CLKEXT`: Clock principal
- `RST_GLO`: Reset global (ativo alto)
- `START`: Sinal de início (1 ciclo)
- `SSFR[15:0]`: Registrador de status/controle
- `CON_SIG[15:0]`: Sinais de controle
- `DA[7:0], DB[7:0], DC[7:0], DD[7:0]`: Dados de entrada (4 vias)
- `BIAS_IN[7:0]`: Entrada de bias

### Saídas Principais
- `D_OUT[7:0]`: Saída final multiplexada
- `FIFO_FULL`: Flag FIFO cheia
- `FIFO_EMPTY`: Flag FIFO vazia
- `BUSY`: Indicador de operação em andamento
- `DONE`: Indicador de operação concluída
- `STATE_DEBUG[3:0]`: Estado atual da FSM (debug)

## 🔧 Configuração e Controle

O sistema é controlado através dos registradores `SSFR` e `CON_SIG`:
- **SSFR**: Configurações de status e controle
- **CON_SIG**: Sinais de controle específicos para cada módulo

## 📈 Fluxo de Operação

1. **IDLE**: Aguarda sinal START
2. **LOAD_INPUT**: Carrega dados no buffer de entrada
3. **COMPUTE**: Executa operações MAC
4. **RELU_STAGE**: Aplica função ReLU e habilita comparador
5. **WRITE_FIFO**: Escreve resultado na FIFO
6. **OUTPUT_SHIFT**: Saída de dados através do PISO
7. **DEBUG_MODE**: Modo de debug opcional
8. **FINISH**: Operação concluída, retorna ao IDLE

## 📚 Documentação

- **NPU_V7.1_Datasheet.pdf**: Documentação oficial da arquitetura NPU V7.1
- **relatorio_de_desenvolvimento.docx**: Relatório de desenvolvimento do projeto

## 🤝 Contribuições

Este projeto foi desenvolvido como parte de um trabalho acadêmico. Contribuições e melhorias são bem-vindas!

## 📄 Licença

Este projeto é distribuído sob licença acadêmica para fins educacionais.
