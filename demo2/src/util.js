const handleData = (content) => {
        
    let line = content.split('\n')

    let mix = line.map(l => {
        return l.split(',')
    })
    // console.info(mix)

    let getLine = (index) => {
        return mix[index]
    } 

    // console.info(getLine(3))

    let getColum = (index) => {
        return mix.map(line => {
            return line[index]
        })
    }

    console.info(getColum(1))

    // 获取经销商
    let boss = getColum(0).map((i, ii) => {
        return {
            pos: ii,
            bos: i
        }
    }).filter(o => o.bos != '').filter((o, p) => p != 0)
    // console.info(boss)

    // 获取带商品的
    let boosWithFoods = boss.map(b => {
        return {
            ...b,
            foods: getLine(b.pos).slice(2).filter(i => i != '')
        }
    })

    // console.info(boosWithFoods)

    let bfWithMember = boosWithFoods.reduce((pre, next, index, arr) => {
        let start = pre.pos
        let end = next.pos -1 
        arr[index-1].start = start
        arr[index-1].end = end
        arr[index-1].members = mix.map((v, i) => {
            let res = []
            if (i > start && i <= end) {
            res.push(v.map(i => { return i == '' ? '0' : i}).slice(1))
            }
            return res + ''
        }).filter(res => res.length != 0) 

        if (index == arr.length -1) {
            arr[index].start = end+1
            arr[index].end = mix.length -1
            arr[index].members = mix.map((v, i) => {
                let res = []
                if (i > arr[index].start  && i <= arr[index].end ) {
                res.push(v.map(i => { return i == '' ? '0' : i}).slice(1))
                console.info(res)
                }
                return res + ''
            }).filter(res => res.length != 0) 
        }
        return next
    })
    console.info(boosWithFoods) 
    console.info(bfWithMember)
}



const handleList = (content) => {
    let result = null
    let line = content.split('\n')
    console.info(result)
    const STORE_ID_COL = 0
    const STORE_NAME_COL = 1
    const COMM_COL = 2
    const COMM_TIME = 3
    const BOSS_ID_COL = 4
    const BOOS_COL = 5
    COMM_TIME
    line = line.filter((i,index) => {
        return i != '' && index != 0
    })
    // console.info(line)
    result = new Map()
    let mix = line.map(i => {
        return i.split(',')
    })
    mix.forEach(item => {
        let bossId =  "id" + item[BOSS_ID_COL].trim()
        let info = result.get(bossId)
        if (info == null) {
            info = {
                count :0,
                name: item[BOOS_COL].trim(),
                id: bossId,
                subs: new Map(),
                coms: function () {
                    let subs = Array.from(this.subs.values())
                    let res = []
                    subs.map((sub) => {
                        Array.from(sub.coms.values()).forEach((com) => {
                            if (res.indexOf(com.name) == -1) {
                                res.push(com.name)
                            }
                        }) 
                    })
                    return res
                },
                getMembers: function () {
                    let subs = Array.from(this.subs.values())
                    let allcs = new Map()

                    subs =  subs.map((sub) => {
                        return sub.name + ',' + this.coms().map((c) =>  {
                            let count = sub.coms.get(c) ? sub.coms.get(c).count : 0
                            allcs.set(c, allcs.get(c) != null ? allcs.get(c)  + count : count )
                            return count
                        }).join(',')
                    })
                    console.info(allcs)
                    subs.push('All'+ ',' + this.coms().map((c) =>  {
                        let count = allcs.get(c)
                        return count
                    }).join(','))
                    return subs
                },
                to: function() {
                    return {
                        bos: this.name,
                        foods: this.coms(),
                        members: this.getMembers()
                    }
                }
            }
        }
        info.count++
        let sub = info.subs.get(item[STORE_ID_COL])
        if (sub == null) {
            sub = {
                name: item[STORE_NAME_COL],
                id: item[STORE_ID_COL],
                coms: new Map()
            }
        }

        let [comName, comCount] = item[COMM_COL].split(' ')

        let preCount = comCount
        comCount = Number.parseInt(comCount)
        if (Number.isNaN(comCount)) {
            console.error('parse number error', comName, preCount)
        }
        let com = sub.coms.get(comName)
        if (com == null) {
            com = {
                name: comName,
                count: 0
            }
        }
        com.count += comCount

        sub.coms.set(comName, com)

        info.subs.set(item[STORE_ID_COL], sub)
        result.set(bossId, info)
    }) 
    return Array.from(result.values())
}

const handleList2 = (content) => {
    content
    //经销商编号	经销商名称	门店编号	门店名称	核销码	核销积分	发起时间	核销时间

    // const BOOS_ID_COL = 0
    // const BOOS_COL = 1
    // const STORE_ID_COL = 2
    // const STORE_COL = 3
    // const SELL_CODE_COL = 4
    // const SELL_SCORE_COL = 5
    // const TIME_COL = 6
    // const SELL_TIME_COL = 7

    // BOSS STORE SOURCE

    let lines = content.split('\n').filter((i,index) => {
        return i != '' && index != 0
    })
    console.info('util handleList2', lines)
    let storeLines = lines.map(l => {
        return l.split(',')
    }).map(row => {
        
        let [bossId, bossName, storeId, storeName, sellCode, sellScore, time, sellTime] = row
        return {
            boss: {
                name: bossName,
                id: bossId
            },
            store: {
                name: storeName,
                id: storeId
            },
            sell: {
                code: sellCode,
                score: Number.parseInt(sellScore)
            },
            time,
            sellTime
        }
    })

    let res = new Map()
    storeLines.forEach(s => {
        let target = res.get(s.store.id)
        console.info('utils res', res)
        if (target === undefined) {
            target = {
                boss:s.boss,
                store: s.store,
                score: s.sell.score
            }
        } else {
            target.score += s.sell.score
        }
        res.set(s.store.id, target)
    })
    console.info('utils', res)
    return Array.from(res.values())
}
export default {
    handleData,
    handleList,
    handleList2,
}