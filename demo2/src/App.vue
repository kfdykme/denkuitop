<template>
  <div id="app">
    <el-tabs v-model="activeName" type="card">
      <el-tab-pane label="表1" name="first">
        
        
        <div>
          <el-upload
              action="https://jsonplaceholder.typicode.com/posts/"
              :on-change="handleChange"
              :file-list="fileList">
              <el-button size="small" type="primary">点击上传csv</el-button>
            </el-upload> 
          <HelloWorld ref="aa" />
        </div>
      </el-tab-pane>
      <el-tab-pane label="表2" name="second">
        <div>
          <el-upload
              action="https://jsonplaceholder.typicode.com/posts/"
              :on-change="handleChange"
              :file-list="fileList">
              <el-button size="small" type="primary">点击上传csv</el-button>
            </el-upload> 
          <HelloWorld2 ref="ab" />
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script>
import HelloWorld from './components/HelloWorld.vue' 
import HelloWorld2 from './components/HelloWorld2.vue' 
import A from './util.js' 
 var reader = new FileReader();
export default {
  name: 'app',
  components: {
    HelloWorld,
    HelloWorld2
  }, 

  data () {
    return {
      activeName: 'first'
    } 
  },

  created() {
   
    reader.onload = (i) => {
      console.info('---' + i)
    }
    reader.onloadend = (i) => {
      console.info('reader load end', i) 
      if (this.activeName == 'first') {
         this.handleFile(reader.result)
      } else {

         this.handleFile2(reader.result)
      }
    } 
  },
  setup() { 
    
    
  },

  methods: {
    update (list) { 
      console.info(this.$refs.aa.update(list))
    },
    update2 (list) {
      console.info(this.$refs.ab.update(list))
    },
    handleChange (file, fileList) { 
      fileList
      reader.readAsText(file.raw,'gbk') 
    } , 
     handleFile (text) {
      console.info("handleFile Start")
      let infos = A.handleList(text)
      
      console.info("handleFile", infos)
      this.update(infos.map(i => i.to()))
      console.info("handleFile End") 
    },
    handleFile2(text) {
      console.info("handleFile2 Start")
      let infos = A.handleList2(text)
      
      console.info("handleFile2", infos)
      this.update2(infos)
      console.info("handleFile2 End")
    }
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
