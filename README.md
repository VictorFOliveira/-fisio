# +Fisio

Aplicativo mobile offline-first para fisioterapeutas acompanharem pacientes, avaliações e evolução clínica no próprio dispositivo.

## MVP

- Cadastro local de pacientes
- Goniometria
- Força muscular
- Avaliação fisioterapêutica
- Evoluções
- Testes funcionais
- Exportação CSV
- Relatório PDF
- Arquitetura preparada para AdMob e compra única `+Fisio PRO`

## Privacidade

O MVP foi desenhado sem backend: os dados permanecem no aparelho. Antes de uso com dados reais de saúde, revisar LGPD, criptografia/backup, política de privacidade e fluxo de consentimento.

## Desenvolvimento

```bash
flutter pub get
flutter run
```

Se o clone ainda não possuir as pastas nativas do Flutter, execute uma vez:

```bash
flutter create --platforms=android .
flutter pub get
```

> O app não substitui julgamento clínico. Protocolos, escalas e referências devem ser validados por fisioterapeutas antes da publicação.