<template>
  <div> 
    <el-button v-show="data2.length > 0" @click="onOut">Get As a csv file</el-button>
   <div 
            v-for="(t,ti) in data2" v-bind:key="t + ti">
                <el-table
                :data="t"
                style="width: 100%">
                <el-table-column
                    prop="bos"
                    label="一级经销商"
                    width="180">
                </el-table-column> 
                <el-table-column
                    prop="sub"
                    label="零售店"
                    width="180">
                </el-table-column>   
                <el-table-column
                    v-for="(c,ci) in t[0].foods" v-bind:key="c + ci"
                    :prop="'score[' + ci + ']'"
                    :label="c"
                    width="180">
                </el-table-column> 
            </el-table> 
          </div>
  </div>
</template>

<script>
const ipcRenderer = window.electron.ipcRenderer

export default {
  name: 'HelloWorld',
  props: {
    msg: Object
  }, 
     computed: { 
        data2: function() { 
            return this.data.map(table => {
                return table.members.map((i) => {
                return {
                    ...table, 
                    sub: i.split(',').length > 1 ? i.split(',')[0] : 'null' ,
                    score: i.split(',').slice(1)
                }
            })
            })
        }
      },
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
          
          this.dealData(this.data2)
        },
        dealData (ts) {
          let res = ts.map(t => {
            let tt = t[0]
            let header = [tt.bos,'']
            header = header.concat(tt.foods).join(',')
            let rows = []
            tt.members.map (r => {
              rows.push(' ,' + r)
            })
            return [header].concat(rows).join('\n')
          })
          res = res.join('\n')
          console.info(res)
          ipcRenderer.send('result', res)
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
