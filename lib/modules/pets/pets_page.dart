import 'package:material_ui/material_ui.dart';

import 'pets_model.dart';
import 'pets_repository.dart';
import 'pet_portrait.dart';

const ink = Color(0xFF183F38);
const cream = Color(0xFFFAF8F2);

class AdotaiApp extends StatefulWidget {
  final PetsRepository repository;
  const AdotaiApp({super.key, required this.repository});
  @override
  State<AdotaiApp> createState() => _AdotaiAppState();
}

class _AdotaiAppState extends State<AdotaiApp> {
  bool loading = true, busy = false;
  String? error;
  int tab = 0;
  String species = '', size = '', query = '';
  PetsRepository get repo => widget.repository;
  String t(String pt, String en) => repo.state.language == 'pt' ? pt : en;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await repo.load();
    } catch (_) {
      error = 'load';
    }
    if (mounted) setState(() => loading = false);
  }

  Future<bool> act(Future<void> Function() operation) async {
    if (busy) return false;
    setState(() => busy = true);
    var ok = true;
    try {
      await operation();
    } catch (_) {
      ok = false;
    }
    if (mounted) {
      setState(() {
        busy = false;
        if (!ok) error = 'save';
      });
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Adotai • Um novo começo',
    debugShowCheckedModeBanner: false,
    locale: Locale(repo.state.language),
    supportedLocales: const [Locale('pt'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ink,
        primary: ink,
        surface: cream,
      ),
      fontFamily: 'Arial',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w800,
          color: ink,
          height: 1.12,
        ),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
    home: Builder(
      builder: (context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              header(context),
              if (busy) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : error == 'load'
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t(
                                'Não foi possível ler os dados locais.',
                                'Could not read local data.',
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: load,
                              child: Text(t('Tentar novamente', 'Retry')),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                t(
                                  'Os dados foram preservados. Verifique o armazenamento do navegador.',
                                  'Your data was preserved. Check browser storage.',
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : content(context),
              ),
            ],
          ),
        ),
        bottomNavigationBar: MediaQuery.sizeOf(context).width < 720
            ? NavigationBar(
                selectedIndex: tab,
                onDestinationSelected: (v) => setState(() => tab = v),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.pets_outlined),
                    label: t('Explorar', 'Explore'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.favorite_border),
                    label: t('Favoritos', 'Favorites'),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.assignment_outlined),
                    label: t('Solicitações', 'Requests'),
                  ),
                ],
              )
            : null,
      ),
    ),
  );
  Widget header(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: cream,
      border: Border(bottom: BorderSide(color: Color(0xFFE5E7DE))),
    ),
    padding: EdgeInsets.symmetric(
      horizontal: MediaQuery.sizeOf(context).width > 900 ? 48 : 16,
      vertical: 12,
    ),
    child: Row(
      children: [
        const Icon(Icons.pets, color: ink, size: 31),
        const SizedBox(width: 9),
        const Text(
          'adotai',
          style: TextStyle(
            fontSize: 29,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            color: ink,
          ),
        ),
        const Spacer(),
        if (MediaQuery.sizeOf(context).width >= 720)
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: () => setState(() => tab = i),
                child: Text(
                  [
                    t('Encontre um amigo', 'Find a friend'),
                    t('Favoritos', 'Favorites'),
                    t('Solicitações', 'Requests'),
                  ][i],
                  style: TextStyle(
                    fontWeight: tab == i ? FontWeight.w800 : FontWeight.normal,
                    color: ink,
                  ),
                ),
              ),
            ),
          ),
        for (final lang in ['pt', 'en'])
          IconButton(
            tooltip: lang == 'pt'
                ? 'Português (Brasil)'
                : 'English (United Kingdom)',
            isSelected: repo.state.language == lang,
            style: IconButton.styleFrom(
              backgroundColor: repo.state.language == lang
                  ? const Color(0xFFE4EADB)
                  : Colors.transparent,
            ),
            onPressed: busy ? null : () => act(() => repo.setLanguage(lang)),
            icon: LanguageFlag(brazil: lang == 'pt'),
          ),
      ],
    ),
  );
  Widget content(BuildContext context) => SingleChildScrollView(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1256),
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 720 ? 20 : 48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error == 'save')
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MaterialBanner(
                    content: Text(
                      t(
                        'Não foi possível salvar. Seus dados anteriores foram mantidos. Tente a ação novamente.',
                        'Could not save. Previous data was kept. Try the action again.',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => setState(() => error = null),
                        child: Text(t('Fechar', 'Dismiss')),
                      ),
                    ],
                  ),
                ),
              localNotice(),
              const SizedBox(height: 24),
              if (tab == 0) ...[hero(context), const SizedBox(height: 38)],
              if (tab < 2) ...[
                catalogTitle(),
                const SizedBox(height: 20),
                filters(),
                const SizedBox(height: 24),
                petGrid(context),
              ] else
                requests(context),
              const SizedBox(height: 48),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                t(
                  'Feito para conectar histórias. Adotar é um compromisso para a vida.',
                  'Made to connect stories. Adoption is a lifelong commitment.',
                ),
                style: const TextStyle(color: ink),
              ),
              const SizedBox(height: 8),
              Text(
                t(
                  'Adotai • Projeto educacional de Kleber Andrade',
                  'Adotai • An educational project by Kleber Andrade',
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget localNotice() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.shield_outlined, size: 17, color: ink),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          t(
            'MODO LOCAL  •  Animais fictícios. Dados salvos neste navegador. Nenhuma solicitação é enviada.',
            'LOCAL MODE  •  Fictional pets. Saved in this browser. No requests are sent.',
          ),
          style: const TextStyle(fontSize: 12, color: ink, height: 1.5),
        ),
      ),
    ],
  );
  Widget hero(BuildContext context) {
    final small = MediaQuery.sizeOf(context).width < 720;
    final words = Padding(
      padding: EdgeInsets.all(small ? 24 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(
              'PEQUENOS ENCONTROS. GRANDES COMEÇOS.',
              'SMALL ENCOUNTERS. BEAUTIFUL BEGINNINGS.',
            ),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: ink,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            t(
              'O próximo capítulo\ncomeça com um lar.',
              'Their next chapter\nstarts with a home.',
            ),
            style: TextStyle(
              fontSize: small ? 35 : 49,
              fontWeight: FontWeight.w800,
              color: ink,
              height: 1.08,
              letterSpacing: -1.7,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            t(
              'Um novo melhor amigo está esperando por você.\nConheça, se encante e adote com responsabilidade.',
              'A new best friend is waiting for you.\nMeet, fall in love and adopt responsibly.',
            ),
            style: const TextStyle(fontSize: 15, height: 1.6, color: ink),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => showGuide(context),
                icon: const Icon(Icons.favorite_outline, size: 18),
                label: Text(t('Como funciona', 'How it works')),
              ),
              Text(
                t('6 histórias para conhecer', '6 stories to discover'),
                style: const TextStyle(fontSize: 12, color: ink),
              ),
            ],
          ),
        ],
      ),
    );
    final art = Stack(
      children: [
        Positioned.fill(child: PetPortrait(pet: seedPets.first)),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.pets, color: ink),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t(
                      'Luna • especialista em carinho',
                      'Luna • professional cuddle buddy',
                    ),
                    style: const TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        color: const Color(0xFFE8EDDF),
        child: small
            ? Column(
                children: [
                  words,
                  SizedBox(height: 245, child: art),
                ],
              )
            : IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(flex: 6, child: words),
                    Expanded(flex: 4, child: art),
                  ],
                ),
              ),
      ),
    );
  }

  Widget catalogTitle() => Wrap(
    alignment: WrapAlignment.spaceBetween,
    runSpacing: 8,
    spacing: 24,
    children: [
      Text(
        tab == 0
            ? t('Encontre seu novo amigo', 'Find your new friend')
            : t('Amigos que você guardou', 'Friends you saved'),
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -.7,
        ),
      ),
      Text(
        t('Todo amor merece um lar.', 'Every love deserves a home.'),
        style: const TextStyle(height: 2.6, color: ink),
      ),
    ],
  );
  Widget filters() => LayoutBuilder(
    builder: (context, box) => Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: box.maxWidth < 600 ? box.maxWidth : 280,
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: t('Buscar pelo nome', 'Search by name'),
            ),
          ),
        ),
        for (final item in [
          ('', t('Todos', 'All pets')),
          ('dog', t('Cães', 'Dogs')),
          ('cat', t('Gatos', 'Cats')),
        ])
          ChoiceChip(
            label: Text(item.$2),
            selected: species == item.$1,
            onSelected: (_) => setState(() => species = item.$1),
          ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: size,
            decoration: InputDecoration(labelText: t('Porte', 'Size')),
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(t('Todos os portes', 'All sizes')),
              ),
              ...['small', 'medium', 'large'].map(
                (s) => DropdownMenuItem(value: s, child: Text(sizeLabel(s))),
              ),
            ],
            onChanged: (v) => setState(() => size = v ?? ''),
          ),
        ),
      ],
    ),
  );
  String sizeLabel(String s) => switch (s) {
    'small' => t('Pequeno', 'Small'),
    'medium' => t('Médio', 'Medium'),
    _ => t('Grande', 'Large'),
  };
  String genderLabel(Pet p) =>
      p.gender == 'female' ? t('Fêmea', 'Female') : t('Macho', 'Male');
  String ageLabel(Pet p) => t(
    '${p.age} ${p.age == 1 ? 'ano' : 'anos'}',
    '${p.age} ${p.age == 1 ? 'year' : 'years'}',
  );
  String natureLabel(Pet p) => switch (p.nature) {
    'gentle' => t('Carinhoso', 'Affectionate'),
    'curious' => t('Curioso', 'Curious'),
    _ => t('Brincalhão', 'Playful'),
  };
  Widget petGrid(BuildContext context) {
    final pets = filterPets(
      seedPets.where((p) => tab == 0 || repo.state.favorites.contains(p.id)),
      species: species,
      size: size,
      query: query,
    );
    if (pets.isEmpty) {
      return empty(
        t('Nenhum amigo por aqui ainda.', 'No friends here yet.'),
        t(
          'Experimente outros filtros ou salve um favorito.',
          'Try other filters or save a favorite.',
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, box) {
        final columns = box.maxWidth > 900
            ? 3
            : box.maxWidth > 550
            ? 2
            : 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(
                pets.length == 1
                    ? '1 amigo esperando um novo começo'
                    : '${pets.length} amigos esperando um novo começo',
                pets.length == 1
                    ? '1 friend waiting for a new beginning'
                    : '${pets.length} friends waiting for a new beginning',
              ),
              style: const TextStyle(fontSize: 12, color: ink),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 22,
              runSpacing: 22,
              children: pets
                  .map(
                    (p) => SizedBox(
                      width: (box.maxWidth - 22 * (columns - 1)) / columns,
                      child: petCard(context, p),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget petCard(BuildContext context, Pet p) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE6E8E0)),
      borderRadius: BorderRadius.circular(20),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Semantics(
                label: t(
                  'Ilustração de ${p.name}',
                  'Illustration of ${p.name}',
                ),
                child: PetPortrait(pet: p),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton.filledTonal(
                tooltip: repo.state.favorites.contains(p.id)
                    ? t('Remover dos favoritos', 'Remove favorite')
                    : t('Salvar favorito', 'Save favorite'),
                onPressed: busy
                    ? null
                    : () => act(() => repo.toggleFavorite(p.id)),
                icon: Icon(
                  repo.state.favorites.contains(p.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: ink,
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: cream,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  natureLabel(p),
                  style: const TextStyle(
                    fontSize: 11,
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: ink,
                      ),
                    ),
                  ),
                  Text(
                    genderLabel(p),
                    style: const TextStyle(color: ink, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                '${ageLabel(p)}  •  ${sizeLabel(p.size)}  •  SRD',
                style: const TextStyle(color: ink, fontSize: 12),
              ),
              const SizedBox(height: 17),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => detail(context, p),
                  child: Text(t('Conheça ${p.name}  →', 'Meet ${p.name}  →')),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget empty(String title, String subtitle) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(38),
    decoration: BoxDecoration(
      color: const Color(0xFFE8EDDF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        const Icon(Icons.pets, color: ink, size: 38),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        const SizedBox(height: 10),
        Text(subtitle, textAlign: TextAlign.center),
      ],
    ),
  );
  void showGuide(BuildContext context) => showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(t('Um encontro responsável', 'A responsible match')),
      content: Text(
        t(
          '1. Conheça o perfil e as necessidades do animal.\n\n2. Preencha uma solicitação com dados fictícios.\n\n3. Acompanhe e simule um encontro e a conclusão.\n\nEste projeto é uma demonstração local. Na vida real, converse com uma organização de confiança e prepare seu lar.',
          '1. Meet the pet and understand their needs.\n\n2. Apply using fictional details.\n\n3. Track and simulate a meeting and completion.\n\nThis is a local demo. In real life, talk to a trusted organization and prepare your home.',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: Text(t('Entendi', 'Got it')),
        ),
      ],
    ),
  );
  void detail(BuildContext context, Pet p) => showDialog<void>(
    context: context,
    builder: (c) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: PetPortrait(pet: p),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton.filledTonal(
                      tooltip: t('Fechar', 'Close'),
                      onPressed: () => Navigator.pop(c),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 32,
                        color: ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${genderLabel(p)} • ${ageLabel(p)} • ${sizeLabel(p.size)} • SRD',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t(
                        '${p.name} adora companhia e está à procura de uma rotina com carinho, brincadeiras e cuidados. Uma adaptação tranquila e acompanhamento veterinário fazem parte desse novo começo.',
                        '${p.name} loves company and is looking for affection, playtime and care. A gentle settling-in period and veterinary care are part of this new beginning.',
                      ),
                      style: const TextStyle(height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t(
                        'Perfil fictício • Castração e vacinas: confirmar em uma adoção real. Não há localização ou abrigo real associado.',
                        'Fictional profile • Neutering and vaccinations: verify in a real adoption. No real shelter or location is associated.',
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(c);
                        application(context, p);
                      },
                      child: Text(
                        t(
                          'Quero adotar • simulação',
                          'Apply to adopt • simulation',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Future<void> application(BuildContext context, Pet p) async {
    final name = TextEditingController(),
        email = TextEditingController(),
        home = TextEditingController();
    final form = GlobalKey<FormState>();
    bool accepted = false, sending = false;
    String? formError;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => StatefulBuilder(
        builder: (c, update) => AlertDialog(
          title: Text(t('Um lar para ${p.name}', 'A home for ${p.name}')),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t(
                        'Simulação local. Use dados fictícios. Nada será enviado; os dados ficam neste navegador.',
                        'Local simulation. Use fictional details. Nothing is sent; details stay in this browser.',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: name,
                      decoration: InputDecoration(
                        labelText: t('Nome fictício', 'Fictional name'),
                      ),
                      validator: (v) => (v ?? '').trim().length < 2
                          ? t(
                              'Informe pelo menos 2 caracteres.',
                              'Enter at least 2 characters.',
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: t('E-mail fictício', 'Fictional email'),
                        hintText: 'ana@example.test',
                      ),
                      validator: (v) =>
                          validateApplication(
                                'Ana',
                                v ?? '',
                                'A safe home for a pet.',
                              ) ==
                              'email'
                          ? t(
                              'Informe um e-mail válido.',
                              'Enter a valid email.',
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: home,
                      maxLines: 3,
                      maxLength: 1000,
                      decoration: InputDecoration(
                        labelText: t(
                          'Como seria o novo lar?',
                          'What would their home be like?',
                        ),
                      ),
                      validator: (v) => (v ?? '').trim().length < 20
                          ? t(
                              'Descreva em pelo menos 20 caracteres.',
                              'Describe in at least 20 characters.',
                            )
                          : null,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: accepted,
                      onChanged: sending
                          ? null
                          : (v) => update(() => accepted = v ?? false),
                      title: Text(
                        t(
                          'Entendo o compromisso de uma adoção responsável.',
                          'I understand the commitment of responsible adoption.',
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    if (formError != null)
                      Text(
                        formError!,
                        style: TextStyle(color: Theme.of(c).colorScheme.error),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: sending ? null : () => Navigator.pop(c),
              child: Text(t('Voltar', 'Back')),
            ),
            FilledButton(
              onPressed: sending
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      if (!accepted) {
                        update(
                          () => formError = t(
                            'Confirme o compromisso para continuar.',
                            'Confirm the commitment to continue.',
                          ),
                        );
                        return;
                      }
                      if (repo.state.requests.any(
                        (r) =>
                            r.petId == p.id &&
                            r.status != AdoptionStatus.cancelled,
                      )) {
                        update(
                          () => formError = t(
                            'Já existe uma solicitação. Veja a aba Solicitações.',
                            'A request already exists. Open Requests.',
                          ),
                        );
                        return;
                      }
                      update(() => sending = true);
                      final ok = await act(
                        () =>
                            repo.apply(p.id, name.text, email.text, home.text),
                      );
                      if (!c.mounted) return;
                      if (ok) {
                        Navigator.pop(c);
                        setState(() => tab = 2);
                      } else {
                        update(() {
                          sending = false;
                          formError = t(
                            'Falha ao salvar. Tente novamente.',
                            'Save failed. Please retry.',
                          );
                        });
                      }
                    },
              child: Text(
                sending
                    ? t('Salvando…', 'Saving…')
                    : t('Salvar solicitação local', 'Save local request'),
              ),
            ),
          ],
        ),
      ),
    );
    // Dispose after the dialog closing animation has released its fields.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose();
    email.dispose();
    home.dispose();
  }

  String statusLabel(AdoptionStatus status) => switch (status) {
    AdoptionStatus.submitted => t('Solicitação salva', 'Request saved'),
    AdoptionStatus.meeting => t('Encontro simulado', 'Meeting simulated'),
    AdoptionStatus.completed => t(
      'Adoção simulada concluída',
      'Simulated adoption completed',
    ),
    AdoptionStatus.cancelled => t('Cancelada', 'Cancelled'),
  };
  Widget requests(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        t('Cada passo, mais perto.', 'Every step, a little closer.'),
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        t(
          'Acompanhe suas solicitações locais. As etapas abaixo são simulações controladas por você.',
          'Track local requests. The steps below are simulations you control.',
        ),
      ),
      const SizedBox(height: 24),
      if (repo.state.requests.isEmpty)
        empty(
          t(
            'Sua história começa no catálogo.',
            'Your story starts in the catalog.',
          ),
          t(
            'Conheça um animal e salve uma solicitação local.',
            'Meet a pet and save a local request.',
          ),
        ),
      for (final r in repo.state.requests.reversed)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE1E5DA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seedPets.firstWhere((p) => p.id == r.petId).name,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${statusLabel(r.status)} • ${r.createdAt.toLocal().toIso8601String().substring(0, 10)}',
                ),
                const SizedBox(height: 12),
                Text(
                  t(
                    '1. Solicitação → 2. Encontro → 3. Adoção',
                    '1. Request → 2. Meeting → 3. Adoption',
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (r.status == AdoptionStatus.submitted ||
                        r.status == AdoptionStatus.meeting) ...[
                      FilledButton(
                        onPressed: busy
                            ? null
                            : () => act(
                                () => repo.transition(
                                  r.petId,
                                  r.status == AdoptionStatus.submitted
                                      ? AdoptionStatus.meeting
                                      : AdoptionStatus.completed,
                                ),
                              ),
                        child: Text(
                          r.status == AdoptionStatus.submitted
                              ? t('Simular encontro', 'Simulate meeting')
                              : t('Concluir simulação', 'Complete simulation'),
                        ),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => act(
                                () => repo.transition(
                                  r.petId,
                                  AdoptionStatus.cancelled,
                                ),
                              ),
                        child: Text(
                          t('Cancelar solicitação', 'Cancel request'),
                        ),
                      ),
                    ],
                    if (r.status == AdoptionStatus.cancelled)
                      OutlinedButton(
                        onPressed: () => application(
                          context,
                          seedPets.firstWhere((p) => p.id == r.petId),
                        ),
                        child: Text(t('Tentar novamente', 'Try again')),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ],
  );
}
