# +Fisio

Aplicativo mobile **offline-first** para fisioterapeutas acompanharem pacientes, avaliações e evolução clínica no próprio dispositivo.

## Estado atual do MVP

O projeto já possui fluxo local de pacientes e prontuário clínico, com persistência SQLite criptografada no aparelho.

### Pacientes

- Cadastro de paciente com nome, data de nascimento, sexo, telefone e e-mail.
- Dados físicos: peso e altura; a ficha calcula e exibe IMC quando os dois valores estão disponíveis.
- Informações clínicas: diagnóstico médico informado, queixa principal, comorbidades, medicamentos, alergias, cirurgias/histórico relevante, restrições/precauções, profissional que encaminhou e observações gerais.
- Modal de cadastro rolável e com espaçamento consistente para telas menores.
- Após salvar, o app confirma o cadastro e abre automaticamente a ficha do novo paciente.
- Ficha completa do paciente, reunindo identificação, dados físicos, informações clínicas e quantidade de registros.
- Edição posterior de todos os dados cadastrais e clínicos do paciente, com confirmação visual após salvar.
- Exclusão permanente do paciente com diálogo de confirmação. A exclusão também remove os registros clínicos vinculados.

### Registros clínicos

- Goniometria.
- Força muscular.
- Avaliação fisioterapêutica.
- Evoluções.
- Testes funcionais.
- Linha do tempo de registros por paciente.
- Evolução e gráficos.

### Exportação / PRO

- Exportação CSV.
- Relatório PDF.
- Arquitetura preparada para recursos `+Fisio PRO`.

## Persistência e segurança

O MVP funciona sem backend. Os dados permanecem localmente no dispositivo em banco SQLite com SQLCipher. A chave de criptografia é mantida por `flutter_secure_storage`.

O banco utiliza relacionamentos com `ON DELETE CASCADE`, portanto a exclusão permanente de um paciente também exclui avaliações, evoluções, medições e testes vinculados.

Antes de uso em produção com dados reais de saúde, ainda devem ser revisados os requisitos aplicáveis de LGPD, política de privacidade, consentimento, estratégia de backup/restauração e segurança operacional.

## Fluxo do paciente

`Pacientes → Novo paciente → Salvar → Confirmação → Ficha do paciente`

A partir da ficha é possível consultar os dados cadastrais/clínicos, editar informações, registrar novas avaliações e acompanhar a linha do tempo e a evolução.

## Banco de dados

Versão atual: **3**.

A migração para a versão 3 adicionou ao paciente os campos de sexo, peso, altura e informações clínicas detalhadas. Instalações existentes são migradas sem recriar o banco.

## CI / Android

O repositório possui GitHub Actions para instalar dependências, analisar/testar o projeto e compilar o APK Android de debug. O APK gerado pelo workflow é disponibilizado como artifact da execução.

## Desenvolvimento

```bash
flutter pub get
flutter run
```

Para validar antes de enviar alterações:

```bash
flutter analyze
flutter test
```

Para gerar um APK localmente:

```bash
flutter build apk --debug
```

Se o clone ainda não possuir as pastas nativas do Flutter, execute uma vez:

```bash
flutter create --platforms=android .
flutter pub get
```

## Diretriz clínica

O +Fisio é uma ferramenta de registro e acompanhamento. O aplicativo **não substitui julgamento clínico** e não determina diagnóstico ou tratamento. Protocolos, escalas e referências devem ser validados por profissionais habilitados antes da publicação.
