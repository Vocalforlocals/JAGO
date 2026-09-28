import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  ClipboardCheck, 
  Filter, 
  Search, 
  AlertCircle, 
  CheckCircle2, 
  Clock, 
  ArrowRight,
  ShieldAlert,
  ChevronRight
} from 'lucide-react';
import { adminApi } from '../services/adminApi';

export default function ReviewQueue() {
  const navigate = useNavigate();
  const [cases, setCases] = useState([]);
  const [activeFilter, setActiveFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadCases() {
      setLoading(true);
      const data = await adminApi.getReviewQueue(activeFilter);
      setCases(data);
      setLoading(false);
    }
    loadCases();
  }, [activeFilter]);

  const filteredCases = cases.filter(c => 
    c.student_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    c.case_number.toLowerCase().includes(searchQuery.toLowerCase()) ||
    c.issue_type.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const filterButtons = [
    { key: 'all', label: 'All Cases' },
    { key: 'pending', label: 'Pending' },
    { key: 'high_priority', label: 'High Priority' },
    { key: 'institution_mismatch', label: 'Institution Mismatch' },
    { key: 'income_mismatch', label: 'Income Mismatch' },
    { key: 'resolved', label: 'Resolved' },
  ];

  return (
    <div className="p-8 space-y-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <div className="flex items-center space-x-2">
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Manual Review Queue</h1>
            <span className="bg-amber-100 text-amber-800 text-xs px-2.5 py-0.5 rounded-full font-semibold border border-amber-300">
              Discrepancy Resolution
            </span>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Cases routed automatically by the Verification Orchestrator when data mismatches or certificate ambiguities occur
          </p>
        </div>
      </div>

      {/* Explanatory Banner */}
      <div className="bg-emerald-50 border border-emerald-200 rounded-xl p-4 flex items-start space-x-3 text-xs text-emerald-900">
        <ShieldAlert className="w-5 h-5 text-emerald-600 shrink-0 mt-0.5" />
        <div>
          <span className="font-bold block mb-0.5">Tolerance & Zero-Wrongful-Rejection Principle</span>
          <span>
            Instead of auto-rejecting tribal students due to minor spelling or alias mismatches (such as "ABC Institute of Technology" vs "ABC Institute of Engineering"), JAGO routes cases here for officer verification so genuine students are protected.
          </span>
        </div>
      </div>

      {/* Controls: Search and Filters */}
      <div className="bg-white rounded-xl border border-slate-200/90 p-4 shadow-sm space-y-4">
        <div className="flex flex-col md:flex-row gap-4 items-center justify-between">
          <div className="relative w-full md:w-80">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
            <input
              type="text"
              placeholder="Search by student name, case #..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg text-xs text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:bg-white"
            />
          </div>

          <div className="flex items-center space-x-1.5 overflow-x-auto w-full md:w-auto pb-2 md:pb-0">
            {filterButtons.map((btn) => (
              <button
                key={btn.key}
                onClick={() => setActiveFilter(btn.key)}
                className={`px-3 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition ${
                  activeFilter === btn.key
                    ? 'bg-slate-900 text-white shadow-sm'
                    : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                }`}
              >
                {btn.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Case Table / Cards */}
      <div className="bg-white rounded-xl border border-slate-200/90 shadow-sm overflow-hidden">
        {loading ? (
          <div className="p-12 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600 mx-auto"></div>
            <p className="text-xs text-slate-500 mt-2">Loading cases...</p>
          </div>
        ) : filteredCases.length === 0 ? (
          <div className="p-12 text-center text-slate-500 text-xs">
            No discrepancy cases match the selected filter.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50/80 text-slate-600 font-semibold border-b border-slate-200/80 uppercase tracking-wider text-[11px]">
                <tr>
                  <th className="py-3.5 px-6">Case ID</th>
                  <th className="py-3.5 px-6">Student Name</th>
                  <th className="py-3.5 px-6">Discrepancy Type</th>
                  <th className="py-3.5 px-6">Priority</th>
                  <th className="py-3.5 px-6">Status</th>
                  <th className="py-3.5 px-6">Date Queued</th>
                  <th className="py-3.5 px-6 text-right">Action</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {filteredCases.map((c) => {
                  const isPending = c.status === 'Pending';
                  const isResolved = c.status === 'Resolved';

                  return (
                    <tr 
                      key={c.id} 
                      className="hover:bg-slate-50/80 transition cursor-pointer"
                      onClick={() => navigate(`/admin/reviews/${c.case_number}`)}
                    >
                      <td className="py-4 px-6 font-mono font-bold text-slate-800">
                        #{c.case_number}
                      </td>
                      <td className="py-4 px-6 font-semibold text-slate-900">
                        {c.student_name}
                      </td>
                      <td className="py-4 px-6">
                        <span className="inline-flex items-center px-2.5 py-1 rounded-md text-[11px] font-medium bg-amber-50 text-amber-800 border border-amber-200">
                          {c.issue_type}
                        </span>
                      </td>
                      <td className="py-4 px-6">
                        <span className={`inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold ${
                          c.priority === 'High' 
                            ? 'bg-rose-100 text-rose-800' 
                            : c.priority === 'Medium'
                            ? 'bg-amber-100 text-amber-800'
                            : 'bg-slate-100 text-slate-700'
                        }`}>
                          {c.priority}
                        </span>
                      </td>
                      <td className="py-4 px-6">
                        <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-[11px] font-semibold ${
                          isResolved 
                            ? 'bg-emerald-100 text-emerald-800'
                            : isPending 
                            ? 'bg-amber-100 text-amber-800'
                            : 'bg-blue-100 text-blue-800'
                        }`}>
                          {isResolved && <CheckCircle2 className="w-3 h-3 mr-1" />}
                          {isPending && <Clock className="w-3 h-3 mr-1" />}
                          {c.status}
                        </span>
                      </td>
                      <td className="py-4 px-6 text-slate-500">
                        {c.created_at}
                      </td>
                      <td className="py-4 px-6 text-right">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            navigate(`/admin/reviews/${c.case_number}`);
                          }}
                          className="inline-flex items-center px-3 py-1.5 rounded-md bg-emerald-600 hover:bg-emerald-700 text-white text-[11px] font-semibold transition"
                        >
                          <span>Review</span>
                          <ChevronRight className="w-3.5 h-3.5 ml-1" />
                        </button>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
