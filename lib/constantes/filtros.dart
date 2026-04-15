// Categorias de receita disponíveis no app
const List<String> categorias = [
  'Café da manhã',
  'Almoço',
  'Jantar',
  'Lanche',
];

// Opções de filtro por tempo máximo de preparo.
// value null representa "+1 hora" (sem limite superior).
const List<Map<String, dynamic>> temposFiltro = [
  {'label': '5 min', 'value': 5},
  {'label': '15 min', 'value': 15},
  {'label': '30 min', 'value': 30},
  {'label': '1 hora', 'value': 60},
  {'label': '+1 hora', 'value': null},
];
