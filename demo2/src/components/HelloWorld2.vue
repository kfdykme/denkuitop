<template>
  <div> 
    <el-button v-show="data.length > 0" @click="onOut">Get As a csv file</el-button>
 
        <el-table
        :data="data"
        style="width: 100%">
        <el-table-column
            prop="boss.name"
            label="一级经销商"
            width="180">
        </el-table-column> 
        <el-table-column
            prop="store.name"
            label="零售店"
            width="180">
        </el-table-column>   
        <el-table-column
            prop="score"
            label="核销积分"
            width="180">
        </el-table-column> 
    </el-table> 
  </div>
</template>

<script>
const ipcRenderer = window.electron.ipcRenderer

export default {
  name: 'HelloWorld2',
 
      data: function() {
        return { visible: false,
        data:[] }
      },
      methods: {
        update (list) {
          this.data = list
          console.info(list)
        },
        onOut () {
          
          this.dealData(this.data)
        },
        dealData (ts) {
          
          let header = '经销商名称, 门店名称, 核销积分'
          let res = []

          res = ts.map(i => {
            return [ i.boss.name, i.store.name, i.score].join(',') 
          })

          res = [header].concat(res).join('\n')
          console.info(res)
          ipcRenderer.send('result2', res)
        }
      }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
