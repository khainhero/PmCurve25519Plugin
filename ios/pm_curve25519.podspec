#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'pm_curve25519'
  s.version          = '0.5.4'
  s.summary          = 'Flutter plugin to generate curve25519 and sign messages utilizing ed25519'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/khainhero/PmCurve25519Plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Farooq' => 'dallifaro@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency '25519', '~> 2.0.2'
  s.ios.deployment_target = '9.0'
end

