import React, {useState} from "react";
import TableCustom from "@/components/TableList/TableCustom";
import {Button, Card, Col, Form, Input, message, Popconfirm, Row} from "antd";
import {api} from "@/services/services";
import RootInfo from "@/pages/data/industry/rootInfo";
import {POST} from "@/utils/request";
// import IpcTree from "@/pages/data/industry/ipcTree";
// import Details from "@/pages/data/industry/details";

// 表格数据操作
let handleEdit, handleDelete, handleRefresh;
const Index = ({form}) => {
    const [root, setRoot] = useState(false);
    const [initialValue, setInitialValue] = useState({});
    const [selectedRowKeys, setSelectedRowKeys] = useState([]);
    const [detail, setDetail] = useState(false);
    // 搜索区域
    const renderSimpleForm = (form, handleSearch, handleReset) => {
        return (
            <Form>
                <Row gutter={24}>
                    {/*    <Col span={12}>*/}
                    {/*        <Form.Item label="分类号">*/}
                    {/*            {form.getFieldDecorator('industryCode')(<Input placeholder="请输入"/>)}*/}
                    {/*        </Form.Item>*/}
                    {/*    </Col>*/}
                    {/*    <Col span={12}>*/}
                    {/*        <Form.Item label="分类号描述">*/}
                    {/*            {form.getFieldDecorator('industryName')(<Input placeholder="请输入"/>)}*/}
                    {/*        </Form.Item>*/}
                    {/*    </Col>*/}

                    {/*</Row>*/}
                    {/*<Row gutter={24} style={{marginTop: 10}}>*/}
                    <Col span={24}>
                        {/*        <Button htmlType="submit" icon="search" type="primary"*/}
                        {/*                onClick={() => handleSearch()}>查询</Button>*/}
                        {/*        <Button style={{marginLeft: 10}} onClick={handleReset} icon={'reload'}>重置</Button>*/}
                        <Button style={{marginLeft: 10}} icon="plus" type="primary"
                                onClick={() => {
                                    setRoot(true);
                                    setInitialValue({parentCode: '0'})
                                }}>新增产业</Button>
                        {/*<Button style={{marginLeft: 10}} icon="plus" type="primary"*/}
                        {/*        onClick={() => {*/}
                        {/*            POST("/api/pms/v1/data/industry/handle/excel").then(data => console.log(data))*/}
                        {/*        }}>初始化产业数据，将会删除现有数据</Button>*/}
                    </Col>
                </Row>
            </Form>
        )
    };

    const columns = [
        {
            title: '代码',
            dataIndex: 'code',
            width: 200
        },
        {
            title: '产业名称',
            dataIndex: 'name',
            width: 200
        },
        {
            title: '操作',
            dataIndex: 'action',
            width: 300,
            render: (text, record) => {
                const {leaf, id, parentId, children, code, name, hasIpc} = record;
                const isLeaf = leaf === "1";
                const ipc = hasIpc === "1";
                const data = {industryCode: id, industryCodeId: id};
                return (
                    <>
                        <Button icon={"edit"} type={"link"} size={"small"} onClick={() => {
                            setRoot(true);
                            setInitialValue({...data, parentCode: parentId, name});
                        }}>修改产业</Button>
                        {!ipc &&
                        <Button icon={"plus"} type={"link"} size={"small"}
                                onClick={() => {
                                    setRoot(true);
                                    setInitialValue({parentCode: code, name})
                                }}>下级产业</Button>}
                        {parentId !== '0' &&
                        <Popconfirm title="确认删除吗?" onConfirm={() => {
                            POST(api.data.industry.del, data).then(data => {
                                if (data) {
                                    message.success("删除成功");
                                    handleRefresh();
                                }
                            })
                        }}>
                            <Button icon={"delete"} type={"link"} size={"small"}>删除</Button>
                        </Popconfirm>}
                        {/*{ipc &&*/}
                        {/*<Button icon={"eye"} type={"link"} size={"small"}*/}
                        {/*        onClick={() => {*/}
                        {/*            setDetail(true);*/}
                        {/*            setInitialValue({industryCode: id})*/}
                        {/*        }}>详情</Button>}*/}
                    </>
                );
            }
        }];
    const [checkedKeys, setCheckedKeys] = useState([]);
    const [classData, setClassData] = useState({});

    return (
        <>
            <Card style={{minHeight: '100%'}} bodyStyle={{minHeight: '100%'}}>
                <div style={{display: "flex", height: '100%'}}>
                    <div style={{width: '60%'}}>
                        <TableCustom
                            title={() => <span>说明：选择某一个叶子产业后在右边填写分类号并保存</span>}
                            handleEdit={func => handleEdit = func}
                            handleDelete={func => handleDelete = func}
                            handleRefresh={func => handleRefresh = func}
                            rowKey="id"
                            // search={renderSimpleForm}
                            api={api.data.industry.list}
                            nodeName="list"
                            columns={columns}
                            rowSelection={{
                                selectedRowKeys, type: 'radio',
                                onChange: (selectedRowKeys, selectedRows) => {
                                    if (selectedRows.length) {
                                        const row = selectedRows[0];
                                        if (row.parentId === '0') {
                                            message.warning("根节点不能添加分类号");
                                            return;
                                        }
                                        if (row.leaf === '0') {
                                            message.warning("请选择叶子节点");
                                            return;
                                        }
                                        POST(api.data.industry.leaf_list, {industryCode: row.id}).then(data => {
                                            if (data) {
                                                let d = {};
                                                for (const item of data.list) {
                                                    d[item.codeLevel] = item.code;
                                                }
                                                setClassData(d);
                                            }
                                        })
                                    }
                                    setSelectedRowKeys(selectedRowKeys)
                                },
                            }}
                        />
                    </div>
                    <div style={{width: '40%', height: '100%', overflow: "auto", padding: 10}}>
                        {/*{<IpcTree checkedKeys={checkedKeys} setCheckedKeys={setCheckedKeys} selectedRowKeys={selectedRowKeys} handleRefresh={handleRefresh}/>}*/}
                        <div style={{height:'45px'}}/>
                        <Form>
                            <Form.Item label={"大类(不同分类号请用英文逗号“,”隔开)"}>
                                {form.getFieldDecorator('dalei',{initialValue:classData['2']})(<Input.TextArea rows={1} placeholder="请输入"/>)}
                            </Form.Item>
                            <Form.Item label={"小类(不同分类号请用英文逗号“,”隔开)"}>
                                {form.getFieldDecorator('xiaolei',{initialValue:classData['3']})(<Input.TextArea rows={2} placeholder="请输入"/>)}
                            </Form.Item>
                            <Form.Item label={"大组(不同分类号请用英文逗号“,”隔开)"}>
                                {form.getFieldDecorator('dazu',{initialValue:classData['4']})(<Input.TextArea rows={10} placeholder="请输入"/>)}
                            </Form.Item>
                            <Form.Item label={"小组(不同分类号请用英文逗号“,”隔开)"}>
                                {form.getFieldDecorator('xiaozu',{initialValue:classData['5']})(<Input.TextArea rows={5} placeholder="请输入"/>)}
                            </Form.Item>
                            <Form.Item>
                                <Button type={"primary"} icon={'save'} style={{marginLeft: '48%'}} onClick={() => {
                                    if (selectedRowKeys.length <= 0) {
                                        message.warning("请先选择产业");
                                        return;
                                    }
                                    form.validateFields((err, values) => {
                                        if (!err) {
                                            POST(api.data.industry.save, {
                                                ...values,
                                                type: '1',
                                                industryCode: selectedRowKeys[0]
                                            }).then(data => {
                                                if (data) {
                                                    message.success("保存成功");
                                                    handleRefresh();
                                                }
                                            })
                                        }
                                    })
                                }}>保存</Button>
                            </Form.Item>
                        </Form>
                    </div>
                </div>
            </Card>
            {root &&
            <RootInfo visible={root} setVisible={setRoot} initialValue={initialValue} handleRefresh={handleRefresh}/>}
            {/*{detail &&*/}
            {/*<Details visible={detail} setVisible={setDetail} initialValue={initialValue} checkedKeys={checkedKeys}*/}
            {/*         setCheckedKeys={setCheckedKeys}/>}*/}
        </>
    );
};

export default Form.create()(Index);
