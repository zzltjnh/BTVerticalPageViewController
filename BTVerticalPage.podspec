Pod::Spec.new do |s|
  s.name         = "BTVerticalPage"
  s.version      = "1.0.0"
  s.summary      = "PageViewController with vertical direction."
  s.homepage     = "https://github.com/zzltjnh/BTVerticalPageViewController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "zzltjnh" => "zzltjnh@gmail.com" }
  s.source       = { :git => "https://github.com/zzltjnh/BTVerticalPageViewController.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '7.0'

  s.source_files  = "source/**/*.{h,m}"

  end