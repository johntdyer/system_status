%w(rubygems awesome_print ohai json sinatra xmlsimple).each{|lib| require lib}

@@ohai = Ohai::System.new
@@ohai.all_plugins
@@ohai.data 
@@kernel=@@ohai.data["kernel"]

options={}

  def Hash
    def to_xml
      doc = REXML::Document.new XmlSimple.xml_out(self, 'AttrPrefix' => true)
      d = ''
      doc.write(d)
      d
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
    puts @@ohai[:filesystem].to_xml
  end
  get '/ps/?:name?.?:ext' do
      processes={
        :ps=>[],
        :kernel=>[
          :name=>@@kernel["name"],
          :release=>@@kernel["release"],
          :machine=>@@kernel["machine"],
          :version=>@@kernel["version"]
        ]
      }
    
      ps_output = params[:name] ? `ps aux | grep -i #{params[:name]} | grep -v grep` : `ps aux | grep -v grep`
        ps_output.split("\n").each do |pid|
          processes[:ps]<< process_to_hash(pid.split(" "))
        end
        
        case params[:ext]
        when 'json'
          processes.to_json
        when 'xml' 
          processes.to_xml
        else
          processes.to_json
        end
  end