Pod::Spec.new do |s|

  s.name         = "Feuille"
  s.version      = "0.0.1"
  s.summary      = "A customizable foundation for the input view used in the message application."
  s.description  = <<-DESC
                    A customizable foundation for the input view used in the message application.
                   DESC

  s.homepage     = "https://github.com/shima11/Feuille"

  s.license      = "MIT"
  s.author             = { "Shima" => "shima.jin@icloud.com" }

  s.platform     = :ios, "10.0"
  s.source = { :git => 'https://github.com/shima11/Feuille.git', :tag => s.version.to_s }

  s.source_files  = "Feuille", "Feuille/**/*.{swift}"

  s.pod_target_xcconfig     = { 'APPLICATION_EXTENSION_API_ONLY' => 'NO' }

end
