# Gerador de Recibos

App Flutter para geração de recibos de serviços prestados com exportação para PDF, armazenamento local e recursos de segurança.

## Funcionalidades

- ✅ Criação de recibos com campos personalizados
- ✅ Validação de CPF/CNPJ
- ✅ Formatação automática de valores monetários
- ✅ Geração de PDF profissional
- ✅ Armazenamento local com SQLite
- ✅ Histórico de recibos com busca e filtros
- ✅ Verificação de integridade dos recibos
- ✅ Compartilhamento de PDF
- ✅ Estatísticas (total recebido, quantidade de recibos)
- ✅ Tema claro/escuro
- ✅ Tratamento de erros robusto

## Estrutura do Projeto

```
lib/
├── main.dart
├── models/
│   └── recibo_model.dart
├── screens/
│   ├── home_screen.dart
│   ├── criar_recibo_screen.dart
│   ├── visualizar_recibo_screen.dart
│   └── historico_screen.dart
├── widgets/
│   ├── recibo_form_widget.dart
│   ├── recibo_preview_widget.dart
│   └── recibo_card_widget.dart
├── services/
│   ├── database_service.dart
│   ├── pdf_service.dart
│   └── security_service.dart
├── utils/
│   ├── validators.dart
│   ├── formatters.dart
│   └── error_handler.dart
└── theme/
    └── app_theme.dart
```

## Campos do Recibo

- **Pagador**: Nome de quem está pagando (obrigatório)
- **Recebedor**: Nome de quem está recebendo (obrigatório)
- **Outro Agente**: Nome de outro agente envolvido (opcional)
- **Valor**: Valor pago (obrigatório)
- **Descrição**: Descrição do serviço prestado (obrigatório)
- **Data**: Data do pagamento (obrigatório)
- **Forma de Pagamento**: Dinheiro, PIX, Cartão, etc. (obrigatório)
- **CPF/CNPJ**: CPF ou CNPJ (opcional, com validação)
- **Endereço**: Endereço (opcional)

## Instalação

1. Certifique-se de ter o Flutter instalado (versão 3.0.0 ou superior)
2. Clone o repositório
3. Execute `flutter pub get` para instalar as dependências
4. Execute `flutter run` para iniciar o app

## Dependências Principais

- `sqflite`: Banco de dados local SQLite
- `path_provider`: Caminhos do sistema
- `pdf`: Geração de PDF
- `printing`: Impressão e compartilhamento de PDF
- `intl`: Formatação de datas e valores
- `shared_preferences`: Preferências do usuário
- `crypto`: Criptografia e hash
- `flutter_secure_storage`: Armazenamento seguro

## Segurança

- Validação de CPF/CNPJ com algoritmo oficial
- Sanitização de inputs para prevenir SQL injection
- Hash SHA-256 para verificação de integridade dos recibos
- Logs seguros (sem dados sensíveis)
- Tratamento de erros robusto

## Uso

1. **Criar Recibo**: Toque no botão "Criar Novo Recibo" na tela inicial
2. **Preencher Formulário**: Preencha todos os campos obrigatórios
3. **Visualizar Preview**: Após preencher, visualize o recibo antes de salvar
4. **Salvar**: Salve o recibo no banco de dados local
5. **Exportar PDF**: Compartilhe ou salve o recibo como PDF
6. **Histórico**: Acesse o histórico para ver todos os recibos salvos
7. **Buscar**: Use a barra de busca para encontrar recibos específicos
8. **Filtros**: Filtre recibos por data ou valor

## Licença

Este projeto é de código aberto e está disponível sob a licença MIT.

