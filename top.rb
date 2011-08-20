%w(rubygems crack ohai shotgun json sinatra xmlsimple).each{|lib| require lib}

  $ohai = Ohai::System.new
  $ohai.all_plugins
  $ohai.all_plugins
  $kernel=$ohai.data["kernel"]

  class Hash
    def to_xml
      XmlSimple.xml_out(self, 'AttrPrefix' => true)
    end
  end
  
  def process_to_hash(ps)
     return process = {
        :user=>ps[0],
        :pid=>ps[1].to_i,
        :cpu=>ps[2].to_f,
        :memory=>{
          :percent=>ps[3].to_f,
          :vsz=> ps[4].to_i,
          :rss=> ps[5].to_i
          },
        :status=>ps[7],
        :started=>ps[8],
        :time=>ps[9],
        :command=>ps[10]
      }
  end
  
  get '/df' do
    $ohai[:filesystem].to_json
  end
  
  get '/uptime' do
    {:uptime=>$ohai[:uptime]}.to_json
  end
  
  get '/network' do
    $ohai["network"].to_json
  end

  get '/' do 
     $ohai.to_json
  end
  
  get '/who' do 
    {:logged_in=>$ohai[:current_user]}.to_json
  end 
   



  get '/ps/:name(?.)?:ext' do
    pass unless params[:name]
    
      processes={
        :ps=>[],
        :kernel=>[
          :name=>$kernel["name"],
          :release=>$kernel["release"],
          :machine=>$kernel["machine"],
          :version=>$kernel["version"]
        ]
      }
    
        ps_output = `ps aux | grep -i #{params[:name]} | grep -v grep`
        
        # Parse PS output
        ps_output.split("\n").each do |pid|
          processes[:ps]<< process_to_hash(pid.split(" "))
        end
          case params[:ext]
            when 'json' then processes.to_json
            when 'xml' then processes.to_xml
          else 
            processes.to_json
        end
  end
  
get '/ps?' do
  
    processes={
      :ps=>[],
      :kernel=>[
        :name=>$kernel["name"],
        :release=>$kernel["release"],
        :machine=>$kernel["machine"],
        :version=>$kernel["version"]
      ]
    }
    
  ps_output =  `ps aux | grep -v grep`
  ps_output.split("\n").each do |pid|
    processes[:ps]<< process_to_hash(pid.split(" "))
  end
    
  case params[:ext]
    when 'json' then processes.to_json
    when 'xml' then processes.to_xml
    else 
      processes.to_json
  end
  
end
  