Pod::Spec.new do |s|
    s.name             = "lhFMDB"
    s.version          = "1.0.4"
    s.summary          = "test"
    s.description      = "简单易用的轻量级数据库"
    s.homepage         = "https://github.com/saberLiuhui/lhFMDB"
    s.license          = 'MIT'
    #s.author           = { "Harry" => “1293246407@qq.com" }
     s.authors            = { "管理员" => "" }
    s.source           = { :git => "https://github.com/saberLiuhui/lhFMDB.git", :tag => "1.0.4" }
    s.platform     = :ios, '8.0'
    s.requires_arc = true
    s.source_files = 'Tool/*.{h,m}'
    s.dependency 'FMDB'  #依赖关系，该项目所依赖的其他库，如果有多个需要填写多个s.dependency
end