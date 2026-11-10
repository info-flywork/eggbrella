enum RoutePaths {
  splash('/', 'splash'),
  home('/home', 'home'),
  game('/game', 'game'),
  result('/result', 'result'),
  settings('/settings', 'settings'),
  store('/store', 'store');

  const RoutePaths(this.path, this.name);

  final String path;
  final String name;
}
