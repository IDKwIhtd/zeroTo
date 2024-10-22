import React, { useEffect, useState } from 'react';

import { View, Text, } from 'react-native';

import moment from 'moment-timezone';

const App = () => {

const [topics, setTopics] = useState([]);

const fetchData = () => {

fetch('http://localhost:8000/get_results/')

.then(response => response.json())

.then(data => {

if (data.data && data.data.results) {

// results 객체를 배열로 변환

const topicsArray = Object.entries(data.data.results);

console.log("Fetched topics:", topicsArray); // 데이터 확인용

setTopics(topicsArray); 

} else {

console.error('No data found');

}

})

.catch(error => console.error('Error fetching topics:', error));

};

useEffect(() => {

// 최초 데이터 가져오기

fetchData();

}, []);

useEffect(() => {

// 1분마다 데이터 갱신

const interval = setInterval(() => {

fetchData();

}, 60000); // 1분마다 API 호출

return () => clearInterval(interval);

}, []);

// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// //const now = moment();

// const [localTime, setLocalTime] = useState(moment.tz("Asia/Seoul").format("HH:mm:ss:SSS"));

// const localTimezone = moment.tz.guess();

// //const localTime = now.tz(localTimezone).format('YYYY-MM-DD HH:mm:ss:SSS');

// useEffect(() => {

//   const id = setInterval(() => {

//     const newTime =moment.tz.guess().format("YYYY-MM-DD HH:mm:ss:SSS"); // 현재 시간으로 업데이트

//     setLocalTime(newTime);

//   }, 10000000000000);

//   return () => clearInterval(id);

// }, []);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

const localTimezone = moment.tz.guess(); // 자동으로 현재 시간대 추측

const [localTime, setLocalTime] = useState(moment().tz(localTimezone).format('YYYY-MM-DD HH:mm:ss:SSS'));

useEffect(() => {

const id = setInterval(() => {

const now = moment(); // 현재 시간 가져오기

const newTime = now.tz(localTimezone).format('YYYY-MM-DD HH:mm:ss:SSS'); // 현재 시간으로 업데이트

setLocalTime(newTime);

}, 1);

return () => clearInterval(id); // 컴포넌트 언마운트 시 인터벌 정리

}, [localTimezone]);

return (

<View style={{ flex: 1 }}>

<View style={{ flex: 1, backgroundColor:'black',justifyContent: 'center', alignItems: 'center', }}>

<Text style={{ color: 'white' }}>Local Time: {localTime}</Text>

<Text style={{ color: 'white' }}>Timezone: {localTimezone}</Text>

</View>

<View style={{ flex: 4, backgroundColor: 'black', justifyContent: 'center', alignItems: 'center' }}>

{topics.map(([key, value], index) => (

<View key={index} style={{ flexDirection: 'row' }}>

<Text style={{ color: 'white', fontSize: 15, fontStyle: 'italic' }}>{key}</Text>

<Text style={{ color: 'white', fontSize: 15, marginLeft: 10, fontWeight: 500 }}>{value}</Text>

</View>

))}

</View>

{/* <View style={{ flex: 4, backgroundColor: 'black', justifyContent: 'center', alignItems: 'center' }}>

<Text style={{ color: 'white', fontSize: 15 }}>

TOPIC #0 WORD 사고{'\n'}

TOPIC #1 WORD 대선{'\n'}

TOPIC #2 WORD 배추{'\n'}

TOPIC #3 WORD 종합병원{'\n'}

TOPIC #4 WORD 민위원{'\n'}

TOPIC #5 WORD 선거{'\n'}

TOPIC #6 WORD 기후{'\n'}

TOPIC #7 WORD 지역{'\n'}

TOPIC #8 WORD 추진{'\n'}

TOPIC #9 WORD 부대{'\n'}

</Text>

</View> */}

</View>

);

};

export default App;