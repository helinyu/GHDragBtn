Pod::Spec.new do |s|
s.name         = 'GHDragBtn'
s.version      = '0.0.1'
s.summary      = '实现悬浮按钮拖拽'
s.homepage     = 'https://github.com/helinyu/HLYBadge'
s.license      = 'MIT'
s.authors      = { "felix" => "2319979647@qq.com" }
s.platform     = :ios, '7.0'
s.source       = {:git => 'https://github.com/helinyu/GHDragBtn', :tag => s.version}
s.source_files = 'test_drag/test_drag/GHDragBtn/*'
s.requires_arc = true
s.description  = <<-DESC
               a button for using over the keywindow
               DESC
end