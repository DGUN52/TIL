# 쓸 때 마다 버벅이는 ModelMapper
우리는 보안 등 다양한 이유로 객체를 객체 그대로가 아닌 전송용 데이터 구조(DTO)에 담아서 보내야하고, 그 속성들을 일일히 `Builder`등을 이용해 DTO로 옮기는 것은 매우 귀찮은 일이다.

한 객체가 너무 많은 속성을 가지는 것은 일반적으로 바람직하지 않지만.. 어쨌든 데이터 매핑은 피할 수 없는 일이고 이를 간편하게 해줄 수 있는 라이브러리 중 하나가 **ModelMapper**이다.

ModelMapper를 이용하는 <text style="color:red">장점</text>으론
1. 다양한 객체들을 일괄적인 구문으로 처리할 수 있고
2. 별도 로직으로 매핑이 필요한 경우만 설정으로 관리해주면 된다.

**이 글에선 `ModelMapper`을 간단히 사용해보고, 쉽게 놓칠 수 있는 주의점을 소개해본다.**

## # ModelMapper
> **modelmapper 공식 가이드** https://modelmapper.org/user-manual/
본 글에선 객체매핑, 객체리스트 매핑만 소개한다.
그 외의 내용(깊은복사, 속성생략, 조건부매핑 등)은 공식문서를 참고하면 간단하게 사용할 수 있다.

0. 전체 프로젝트 구조(참고)
글이 길어지므로 다음 글에서 Spirng MVC구조에 대한 간단한 고찰을 해보도록 하겠다.
![](https://velog.velcdn.com/images/deaf52/post/246023cc-66df-453f-a6fd-591206041184/image.png)

**1. 의존성 주입**
```java
//maven, 버전확인필요
<dependency>
    <groupId>org.modelmapper</groupId>
    <artifactId>modelmapper</artifactId>
    <version>2.4.2</version>
</dependency>
```
```java
//gradle, 버전확인필요
	implementation 'org.modelmapper:modelmapper:3.1.1'
```
**2. entity와 dto class 생성**
id, name, 생성일 세가지 속성을 가지는 간단한 클래스 생성
실제에선 비밀번호나 주민등록번호 등의 민감정보가 entity엔 있을 것이고 DTO엔 없을 것이다.
```java
//entity
@Getter
@ToString
@Entity
@Table(name = "user")
public class UserEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String name;

    @Column(name = "signed_date", columnDefinition = "datetime", nullable = false)
    private LocalDateTime signedDate;
}
```
```java
//DTO
@Data
@NoArgsConstructor
public class UserResponseDTO {
    private Integer id;
    private String name;
    private LocalDateTime signedDate;
}
```
다음과 같은 사항을 준수해야한다.
❗소스(entity)에는 Getter가 있어야 한다.
❗타겟(dto)에는 Setter와 기본생성자가 있어야한다.
당연히 getter가 없으면 소스 객체의 값을 알 수 없고
타겟에 생성자와 setter가 없으면 값을 넣을 수 없다.

_+jpa이용을 위한 레포지토리도 선언해준다._
```java
//userrepository
@Repository
public interface UserRepository extends JpaRepository<UserEntity, Integer> {}
```

**3. controller, service 생성**
```java
//controller
@RequiredArgsConstructor
@RestController
@RequestMapping("/user")
public class UserController {
    private final UserService userService;

    @GetMapping("/list")
    public ResponseEntity<?> getUserList(){
        return ResponseEntity.ok(userService.getUserList());
    }
}
```
### service 코드 + 매핑 문법(list)
```java
//service
@Service
@RequiredArgsConstructor
public class UserService{
    private final UserRepository userRepository;
    private final ModelMapper modelMapper;

    public List<UserResponseDTO> getUserList(){
        List<UserEntity> userList = userRepository.findAll();
        List<UserResponseDTO> response = userList.stream()
                .map(userEntity -> modelMapper.map(userEntity, UserResponseDTO.class))
                .collect(Collectors.toList());
        return response;
    }
}
```
위 service코드는 db에 저장된 모든 유저를 `userList`에 먼저 담고, 
`response`라는 DTO객체에 modelMapper, stream문법을 이용해 매핑하는 과정이다.

### 매핑 문법(단일 객체)
만약 유저 **리스트**가 아닌 **객체 하나**만 전송하고 싶은 경우 다음과 같이 하면 될 것이다.
```java
//객체 하나만 전송 example
int x = /* 찾고자 하는 유저의 ID */
UserEntity userEntity = userRepository.findById(x);
UserResponseDto response = modelMapper.map(userEntity, UserResponseDTO.class)
```

+. 필요시 modelmapper 클래스를 설정해준다.
```java
@Configuration
public class ModelMapperConfig {
    @Bean
    public ModelMapper modelMapper(){
        ModelMapper modelMapper = new ModelMapper();
        modelMapper.getConfiguration().setMatchingStrategy(MatchingStrategies.LOOSE);
        return modelMapper;
    }
}
```
간단하게 MatchingStrategies만 설정해주었다.
매칭방식은 속성이름을 토큰으로 나눈후 토큰들을 비교하는 방식이다.
(ex: `signedDate` -> `signed` `Date`)

### 매칭전략 설명
**MatchingStrategies.LOOSE**
-> `signedDate`에서 `loginDate`로 매칭이 가능하다. (토큰 하나 일치(Date))

**MatchingStrategies.STANDARD**
-> `signedDate`에서 `loginDate`로 매칭이 되지 않는다. (토큰 일부 불일치)

**MatchingStrategies.STRICT**
-> `signedDate`에서 `loginDate`로 매칭 시도 시 에러발생


### TypeMap 예시
이외의 설정은 대부분 TypeMap을 이용한다고 보면 된다.
간단한 예시를 가져와봤다.
```java
        ModelMapper modelMapper = new ModelMapper();

        // TypeMap 정의 및 매핑 추가 (sourceField -> destinationField)
        TypeMap<SourceClass, DestinationClass> typeMap = modelMapper.createTypeMap(SourceClass.class, DestinationClass.class);
        typeMap.addMapping(SourceClass::getSourceField, DestinationClass::setDestinationField);

        // 매핑 수행
        SourceClass source = new SourceClass("Hello");
        DestinationClass destination = modelMapper.map(source, DestinationClass.class);

        System.out.println(destination.getDestinationField()); // "Hello"
```
이 외에도 유효성 확인을 위한 `validation`
간단한 값 변환을 위한 `converter`
형이 다른 경우의 매칭을 위한 `TypeToken`(generics)
복잡한 로직 및 외부 의존성 주입이 필요할 경우 `provider`
다양한 방식이 있으니 필요할 때 공식사이트의 docs를 참고하면 사용하기 쉬울 듯 하다.
