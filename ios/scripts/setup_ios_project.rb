#!/usr/bin/env ruby
# Dopina do ios/Runner.xcodeproj to, czego nie da się sensownie wpisać ręcznie bez Xcode:
#  - uprawnienia (Runner.entitlements) dla celu Runner,
#  - cel „PorzadMisWidgets” (rozszerzenie WidgetKit) z plikami z ios/PorzadMisWidgets,
#  - osadzenie rozszerzenia w aplikacji.
# Skrypt jest idempotentny (drugie uruchomienie nic nie zmienia). Uruchamiany w CI (codemagic.yaml)
# lub raz na Macu: `ruby ios/scripts/setup_ios_project.rb`. Wymaga gemu `xcodeproj` (jest w CocoaPods).
# UWAGA: napisany bez Maca i nieuruchomiony; po pierwszym uruchomieniu sprawdź projekt w Xcode.
require 'xcodeproj'

ROOT = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(ROOT, 'Runner.xcodeproj')
BUNDLE_ID = 'pl.porzadmis.porzadmis'
EXT_NAME = 'PorzadMisWidgets'
EXT_BUNDLE_ID = "#{BUNDLE_ID}.widgets"

project = Xcodeproj::Project.open(PROJECT_PATH)
runner = project.targets.find { |t| t.name == 'Runner' } or abort('Brak celu Runner')

# 1. Uprawnienia aplikacji.
runner.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end

# 2. Rozszerzenie widżetów.
if project.targets.any? { |t| t.name == EXT_NAME }
  puts "Cel #{EXT_NAME} już istnieje; pomijam."
else
  ext = project.new_target(:app_extension, EXT_NAME, :ios, '15.0')

  group = project.main_group.new_group(EXT_NAME, EXT_NAME)
  swift = group.new_file('PorzadMisWidgets.swift')
  group.new_file('Info.plist')
  group.new_file("#{EXT_NAME}.entitlements")
  ext.add_file_references([swift])

  ext.build_configurations.each do |config|
    s = config.build_settings
    s['PRODUCT_BUNDLE_IDENTIFIER'] = EXT_BUNDLE_ID
    s['PRODUCT_NAME'] = '$(TARGET_NAME)'
    s['INFOPLIST_FILE'] = "#{EXT_NAME}/Info.plist"
    s['CODE_SIGN_ENTITLEMENTS'] = "#{EXT_NAME}/#{EXT_NAME}.entitlements"
    s['SWIFT_VERSION'] = '5.0'
    s['TARGETED_DEVICE_FAMILY'] = '1,2'
    s['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    s['SKIP_INSTALL'] = 'YES'
    s['GENERATE_INFOPLIST_FILE'] = 'NO'
    s['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
    s['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
    s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
  end

  # 3. Osadzenie rozszerzenia w aplikacji. Faza musi stać przed „Thin Binary” Fluttera,
  #    inaczej Xcode zgłasza „Cycle inside Runner”.
  runner.add_dependency(ext)
  embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
  embed.symbol_dst_subfolder_spec = :plug_ins
  build_file = embed.add_file_reference(ext.product_reference, true)
  build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

  runner.build_phases.delete(embed)
  thin = runner.build_phases.find { |ph| ph.respond_to?(:name) && ph.name.to_s.include?('Thin Binary') }
  index = thin ? runner.build_phases.index(thin) : runner.build_phases.length
  runner.build_phases.insert(index, embed)
  puts "Dodano cel #{EXT_NAME} (#{EXT_BUNDLE_ID})."
end

project.save
