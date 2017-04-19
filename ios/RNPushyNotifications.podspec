
Pod::Spec.new do |s|
  s.name          = "RNPushyNotifications"
  s.version       = "1.0.0"
  s.summary       = "RNPushyNotifications"
  s.description   = <<-DESC
                  RNPushyNotifications
                   DESC
  s.homepage       = "https://github.com/healthimation/react-native-pushy-notifications"
  s.license       = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author        = { "author" => "joeleonard@gmail.com" }
  s.platform      = :ios, "7.0"
  s.source        = { :git => "https://github.com/author/RNPushyNotifications.git", :tag => "master" }
  s.source_files  = "RNPushyNotifications/**/*.{h,m}"
  s.requires_arc  = true


  s.dependency "React"
  s.dependency "Pushy"

end
